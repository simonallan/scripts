#!/bin/bash

# Read-in a file of unique S3 Bucket ResourceIDs (ARNs) and then query Cloudformation for
# the stack that created the resource

testrun=true

if [ "$testrun" = true ]; then
  input_file="./src/ofr-prod-s3-unique-arns-test.txt"
else
  input_file="./src/ofr-prod-s3-unique-arns.txt"
fi

datestamp=$(date +"%m%d%Y")

output_file="./output/ofr-prod-bucket-stack-results-$datestamp.txt"

truncate -s 0 $output_file

declare -a noStackBuckets=()
declare -a hasStackBuckets=()
declare -a bucketsWithStacks=()

noStackCounter=0
hasStackCounter=0

printf "Checking IDs listed in $input_file. Please wait...\n"

#Initialises spinner
spin='-\|/'
i=0

# Loop through the input file, checking to see if each bucket is associated with an existing stack
while read bucket;
do
  # It's a spinner!
  i=$(( (i+1) %4 ))
  printf "\r${spin:$i:1}"

  # Strip the preceeding 'arn:aws:s3:::' from bucket ARN
  physicalId="$(echo $bucket | awk -F ':' '{print $6}')"

  stackName="$(aws cloudformation describe-stack-resources \
  --physical-resource-id "$physicalId" \
  --no-cli-pager \
  --output text \
  --query 'StackResources[0].{stackname: StackName, timeStamp: Timestamp}' 2> /dev/null )"

  # command receives validation error 254 if a corresponding stack is not found.
  if [ $? == 254 ]; then
    output="$bucket - Stack does not exist"
    printf "$output\n" >> $output_file
    ((++noStackCounter))
  else
    output="$bucket - created with stack $stackName"
    printf "$output\n" >> $output_file
    ((++hasStackCounter))
    bucketsWithStacks[$end]+="$output"
  fi
done < $input_file

totalBuckets=$(($noStackCounter + $hasStackCounter))
printf "\nTotal Buckets Checked: $totalBuckets\n\n"
printf "Buckets with belonging to existing stack: $hasStackCounter\n"
printf "Buckets with orphaned from creator stack: $noStackCounter\n\n"
printf "The following should probably be checked and NOT deleted:\n"
printf "$bucketsWithStacks"
