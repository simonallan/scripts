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

declare -a noStackResources=()
declare -a hasStackResources=()
declare -a resourcesWithStacks=()

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
  # Thanks to William Purcell at https://stackoverflow.com/questions/12498304/using-bash-to-display-a-progress-indicator-spinner
  i=$(( (i+1) %4 ))
  printf "\r${spin:$i:1}"

  # Strip the preceeding 'arn:aws:s3:::' from resource ARN
  physicalId="$(echo $bucket | awk -F ':' '{print $6}')"

  # Perform a stack resource lookup based on the resource ID
  output="$(aws cloudformation describe-stack-resources \
  --physical-resource-id "$physicalId" \
  --no-cli-pager \
  --output text \
  --query 'StackResources[0].{stackname: StackName, timeStamp: Timestamp}' 2>&1 )"

  if [[ $output == *"ValidationError"* ]]; then
    printf "$(echo $output | awk -F ':' '{print $2}')\n" >> $output_file
    ((++noStackCounter))
  else
    printf "$output\n" >> $output_file
    ((++hasStackCounter))
    resourcesWithStacks[$end]+="$output\n"
  fi
done < $input_file

totalResources=$(($noStackCounter + $hasStackCounter))
printf "\nTotal Resources Checked: $totalResources\n\n"
printf "Resources belonging to existing stack: $hasStackCounter\n"
printf "Resources orphaned from creator stack: $noStackCounter\n\n"

if [ $hasStackCounter -gt 0 ]; then
  printf "The following should be checked and NOT deleted:\n"
  printf "$resourcesWithStacks"
fi
