#!/bin/bash

# Read-in a file of unique S3 Bucket ResourceIDs (ARNs) and then query Cloudformation for
# the stack that created the resource

input_file="./src/ofr-s3-unique-resource-ids.txt"
# input_file="./src/ofr-s3-test-unique-resourceIds.txt"
output_file="./output/find-s3-bucket-owner-stack-results.txt"

truncate -s 0 $output_file

while read -r physicalId;
do
	aws cloudformation describe-stack-resources --physical-resource-id "$physicalId" \
	--no-cli-pager \
	--output text \
	--query 'StackResources[0].{stackname: StackName, timeStamp: Timestamp}'
done < $input_file

