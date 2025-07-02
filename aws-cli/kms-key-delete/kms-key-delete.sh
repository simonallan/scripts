#!/bin/bash

# Get list of all KMS keys physical IDs
keyIdList=$(aws kms list-keys --query 'Keys[*].KeyId' --no-cli-pager)
keyIds=$(echo $keyIdList | tr -d '"[],')

pendingDays=13
countMissing=0
countFound=0
legitkeys=()

# Loop through each key ID and check if it is in use by a CloudFormation stack
for keyId in $keyIds; do
	stackCheck=$(aws cloudformation describe-stack-resources --physical-resource-id "$keyId" \
    --no-cli-pager \
	  --output text \
	  --query 'StackResources[0].{stackname: StackName, timeStamp: Timestamp}' \
    2> /dev/null)

  ret=$?
  if [ $ret -eq 254 ]; then
      echo "No stack found for $keyId"

      # Schedule key deletion
      aws kms schedule-key-deletion \
        --key-id "$keyId" \
        --pending-window-in-days "$pendingDays" \
        --no-cli-pager

      countMissing=$((countMissing+1))
      continue
  elif [ $ret -ne 0 ]; then
      echo "Error checking stack for $keyId"
      continue
  else
    stackName=$(echo "$stackCheck" | awk '{print $1}')
    timeStamp=$(echo "$stackCheck" | awk '{print $2}')
    echo "Key ID: $keyId, Stack Name: $stackName, Timestamp: $timeStamp"

    countFound=$((countFound+1))
    legitKeys+="$keyId"
  fi
done

echo .
echo "Total keys found in stacks: $countFound"
for legitKey in ${legitKeys[@]}; do
  echo -e "$legitKey"
done

echo .
echo "Total number of keys for deletion" $countMissing
