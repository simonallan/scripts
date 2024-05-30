for i in {1..1}; do
#    aws logs describe-log-groups --query 'logGroups[?subscriptionFilters!=`null` && starts_with(subscriptionFilters[0].filterPattern, `arn:aws:lambda:eu-west-2:568819880158:function:StackSet-DataDogForwarderv1`)].logGroupName' --output text && break
    aws logs describe-log-groups --query 'logGroups[?subscriptionFilters!=`null` && starts_with(subscriptionFilters[0].filterPattern, `DD_LOG_SUBSCRIPTION_FILTER`)].logGroupName' --output text >> output.txt && break 
#    sleep $((2**i))
    sleep 1
done

