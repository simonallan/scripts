#!/usr/bin/env bash
# Quick and dirty script to iterate through AWS S3 buckets
# and filch out some details

logfile=/tmp/bucket-details.txt

starttime=$(date +"%m-%d-%Y %T")

# log all output
exec 1>$logfile 2>&1

# Account to check
profile="awsprod"

# List names of all buckets 
buckets=$(aws s3api list-buckets --profile awsprod --query "Buckets[].Name" --output text)

# Iterate over the list of S3 buckets, doing a thing to each one
for b in $buckets; do
  echo $b
  aws s3api get-bucket-logging --bucket $b --profile $profile
  echo ""
done

now=$(date +"%m-%d-%Y %T")
echo "* * * Script started:  $starttime"
echo "* * * Script complete: $now"

