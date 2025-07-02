#!/bin/bash

# Script to get task start-up times in provided ECS Fargate clusters

declare -a clusters=(
  "ofr-fws-application-production"
  "ofr-admin-application-production"
)

for clusterName in "${clusters[@]}"; do
  echo "Cluster: $clusterName"
  aws ecs list-tasks \
    --cluster "$clusterName" \
    --launch-type FARGATE \
    --output text \
    --query 'taskArns[*]' | tr '\t' '\n' | while read -r taskArn; do
      output=$(aws ecs describe-tasks \
        --cluster "$clusterName" \
        --tasks "$taskArn" \
        --query "tasks[].{TaskArn: taskArn, StartedAt: startedAt}" \
        --output text \
        --no-cli-pager)

      # Split into taskArn and startedAt
      taskArnField=$(echo "$output" | awk '{print $1}')
      startedAtRaw=$(echo "$output" | awk '{print $2}')

      # Remove milliseconds (everything after the first dot)
      startedAtFormatted=${startedAtRaw%%.*}

      echo -e "$taskArnField\t$startedAtFormatted"
  done
done

