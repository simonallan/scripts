#!/usr/bin/env bash

# AWS-Cli script that deletes objects, object versions and buckets.

# Usage:
# - Create an input file of a list S3 bucket names (physicalId) that are to be deleted.
# - Execute the script as normal by calling it from the command line
# - We’ll then iterate over the buckets returned from our list-buckets query
#   I wanted to add some kind of failsafe just in case my query picked up some buckets
#   that I might actually need (again this was in a sandbox environment, but
#   you can never be too sure). So we prompt the user for a y input.
# - If you are truly YOLO (or you prepared well - SA), you can use the yes program to
#   automatically accept every result, for example
#   `yes | ./s3-delete-buckets.sh` (Ed)

# input_file="./src/ofr-int-test-s3-deletions-list.txt"
input_file="./src/ofr-int-s3-deletions-latest.txt"

declare -a buckets_array=`cat $input_file`

CHUNK_SIZE=1000 # This is the max number of objects that can be deleted in a single request

for b in $buckets_array; do
    # Credit to Ed in the Clouds for the Empty and Delete S3 Buckets script
    # https://www.edintheclouds.io/posts/e20c3d90-f389-4cc8-9767-d126339a9710

    # Strip the preceeding 'arn:aws:s3:::' from bucket ARN to get the physicalID
    bucket="$(echo $b | awk -F ':' '{print $6}')"

    echo -n "Are you sure you want to delete bucket '$bucket'? Only 'Y/y' is accepted: "
        read -r confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            objects=$(aws s3api list-object-versions --bucket $bucket --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')
            if [[ $(jq '.Objects' <<< $objects) == "null" ]]; then
                echo "Bucket $bucket is empty"
            else
                echo "Deleting objects in bucket $bucket"
                while [[ $(jq '.Objects | length' <<<$objects) -gt 0 ]]; do
                    echo "$(jq '.Objects | length' <<<$objects) objects remaining"
                    objs_to_delete=$(jq "{Objects:.Objects[:$CHUNK_SIZE], Quiet: true}" <<< $objects)
                    aws s3api delete-objects --bucket $bucket --delete "$objs_to_delete"
                    objects=$(jq "del(.Objects[:$CHUNK_SIZE])" <<< $objects)
                done
                if [[ $(aws s3api get-bucket-versioning --bucket $bucket --output text) == "Enabled" ]]; then
                    echo "removing delete markers from $bucket"
                    del_markers=$(aws s3api list-object-versions --bucket $bucket --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')
                    while [[ $(jq '.Objects | length' <<<$del_markers) -gt 0 ]]; do
                        markers_to_delete=$(jq "{Objects:.Objects[:$CHUNK_SIZE], Quiet: true}" <<< $del_markers)
                        aws s3api delete-objects --bucket $bucket --delete "$markers_to_delete"
                        del_markers=$(jq "del(.Objects[:$CHUNK_SIZE])" <<< $del_markers)
                    done
                fi
            fi
            echo "Deleting bucket $bucket"
            aws s3api delete-bucket --bucket $bucket
        else
            echo "Skipping bucket $bucket"
        fi
done
