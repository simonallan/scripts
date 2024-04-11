#!/bin/bash
# Script loops through regions to disable Security Hub then looks for AWS Config setup

declare -a awsregions=(
    "us-east-2"
    "us-east-1"
    "us-west-1"
    "us-west-2"
    "af-south-1"
    "ap-east-1"
    "ap-southeast-3"
    "ap-south-1"
    "ap-northeast-3"
    "ap-northeast-2"
    "ap-southeast-1"
    "ap-southeast-2"
    "ap-northeast-1"
    "ca-central-1"
    "eu-central-1"
    "eu-west-1"
    "eu-west-2"
    "eu-south-1"
    "eu-west-3"
    "eu-north-1"
    "me-south-1"
    "me-central-1"
    "sa-east-1"
    "us-gov-east-1"
    "us-gov-west-1"
)

for i in ${awsregions[@]}; do
    echo . . . AWS region changed to ${i} . . .
    echo Disabling Security Hub
    aws securityhub disable-security-hub --region $i --no-cli-pager

    echo Now checking AWS Config in region ${i}
    aws configservice describe-configuration-recorders --region $i --no-cli-pager
    aws configservice describe-delivery-channels --region $i --no-cli-pager
    aws configservice describe-delivery-channel-status --region $i --no-cli-pager
done

