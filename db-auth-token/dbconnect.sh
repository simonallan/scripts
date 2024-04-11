#!/bin/bash

RDSHOST="ofr-fws-application-integration.cijbd5cnppmo.eu-west-2.rds.amazonaws.com"
RDSPROXY="ofrfwsapplicationintegratipplicationintegrationproxya9bc99b4.proxy-cijbd5cnppmo.eu-west-2.rds.amazonaws.com"
DB=$RDSHOST
USERNAME='proxy'
CABUNDLE='./global-bundle.pem'
TOKEN="$(aws rds generate-db-auth-token --hostname $DB --port 3306 --region eu-west-2 --username $USERNAME )"

echo '========'
echo RDS Primary DB: $RDSHSOST
echo RDS Proxy DB: $RDSPROXY
echo Generating auth token...
echo 'aws rds generate-db-auth-token command returns token:' $TOKEN
echo '========'
echo Establshing connection to DB with token...

mysql                           \
--host=$DB                      \
--port=3306                     \
--user=proxy                    \
--enable-cleartext-plugin       \
--password=$TOKEN               \
--ssl-mode=REQUIRED             \
--ssl-ca=$CABUNDLE              \
-e "status;" | grep -B 1 -A 1 'SSL'

# --ssl-mode
#Alternatives are: 'DISABLED','PREFERRED','REQUIRED','VERIFY_CA','VERIFY_IDENTITY'
