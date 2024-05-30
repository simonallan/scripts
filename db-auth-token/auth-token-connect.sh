#!/bin/bash

# RDSHOST="ofr-fws-application-integration.cijbd5cnppmo.eu-west-2.rds.amazonaws.com"
# RDSPROXY="ofrfwsapplicationintegratipplicationintegrationproxya9bc99b4.proxy-cijbd5cnppmo.eu-west-2.rds.amazonaws.com"
RDSHOST="stg-oauth-mysql-01.cnqq1j8iriww.eu-west-1.rds.amazonaws.com"
DB=$RDSHOST
USERNAME='mysqladm'
CABUNDLE='./global-bundle.pem'
TOKEN="$(aws rds generate-db-auth-token --hostname $DB --port 3306 --region eu-west-2 --username $USERNAME )"

printf "Generating auth token...\n"
printf "\n$TOKEN\n"
printf "Connecting to DB $DB\n"
printf "Establshing connection to DB with token...\n"

mysql                               \
    --host=$DB                      \
    --port=3306                     \
    --user=$USERNAME                \
 #   --enable-cleartext-plugin       \ # Disable for MariaDB-type clients
    --password=$TOKEN               \
    --ssl-mode=REQUIRED             \
    --ssl-ca=$CABUNDLE              \
    -e "status;" | grep -B 1 -A 1 'SSL'

# --ssl-mode
#Alternatives are: 'DISABLED','PREFERRED','REQUIRED','VERIFY_CA','VERIFY_IDENTITY'
