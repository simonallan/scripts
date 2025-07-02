#!/bin/bash

endpoint="bank-verification.dev.pws.app.crnet.org"

declare -a array=( 
  "@8.8.8.8 #Google"
  "@208.67.222.222 #OpenDNS"
  "@1.1.1.1 #CloudFlare"
  "#  CRUK-default"
  "@10.61.239.1 #CRUK"
  "@10.61.239.4 #CRUK"
  "@143.65.1.1 #CRUK"
)

echo "Now testing for endpoint $endpoint"

for a in "${array[@]}"
do
  echo $a
  dig +short $endpoint $a
done




