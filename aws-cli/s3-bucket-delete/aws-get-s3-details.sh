#!/usr/bin/env bash
# Quick and dirty script to iterate through AWS S3 buckets
# and filch out some details

logFile=/output/bucket-details.txt

startTime=$(date +"%m%d%Y-%T")

# log all output
exec 1>$logFile 2>&1

# Account and role to check
profile="ofr-prod-readonly"

# List names of all buckets
buckets=$(aws s3api list-buckets --profile $profile --query "Buckets[].Name" --output text)

# Iterate over the list of S3 buckets, doing a thing to each one
for b in $buckets; do
  echo $b
  aws s3api get-bucket-logging --bucket $b --profile $profile
  echo ""
done

endTime=$(date +"%m%d%Y-%T")

echo "* * * Script started:  $startTime"
echo "* * * Script complete: $endTime"

