#!/bin/bash

# Quick and dirty script to enumerate Dynatrace services

dtcli="python3 /home/allan05/data/Git/dynatrace-cli/dtcli.py"
services="$($dtcli ent srv .*cancerresearchuk.org.*)"
servicesarr=($services)

echo .
echo DTCLI test = $dtcli
echo Services = $services
echo Array = $servicesarr
echo .

for service in $services[@]
do
  printf $service\n
done
