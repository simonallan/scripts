aws logs describe-log-groups --query 'logGroups[].logGroupName' --output text | \
while read -r logGroupName; do \
  destinationArn=$(aws logs describe-subscription-filters --log-group-name "$logGroupName" --query 'subscriptionFilters[0].destinationArn' --output text 2>/dev/null); \
#  if [[ -n "$destinationArn" && "$destinationArn" == 'arn:aws:lambda:eu-west-2' ]]; then \
  if [[ "$destinationArn" == "arn:aws:lambda:eu-west-2" ]]; then \
    echo "$logGroupName" 
  fi 
done
