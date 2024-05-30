#!/bin/bash




declare -a dbendpoints=(
    # 'ofrfwsapplicationintegratipplicationintegrationproxya9bc99b4.proxy-cijbd5cnppmo.eu-west-2.rds.amazonaws.com' # OFR Prod Proxy
    prod-oauth-mysql-01.cnqq1j8iriww.eu-west-1.rds.amazonaws.com # OAuth Prod
)

dbuser="proxy"

declare -a statusCommands=(
    "STATUS;"
    "SHOW GLOBAL VARIABLES LIKE 'require_secure_transport';"
    "SHOW GLOBAL VARIABLES LIKE 'ssl%';"
    "SHOW GLOBAL STATUS LIKE '%conn%';"
    "SHOW GLOBAL STATUS LIKE '%ssl%';"
    "SHOW GLOBAL STATUS LIKE '%finished%';"
    "SHOW VARIABLES LIKE "%version%";"
    "SELECT id, user, host, connection_type FROM performance_schema.threads pst INNER JOIN information_schema.processlist isp ON pst.processlist_id = isp.id;"
)

configfile="/home/as2-streaming-user/MyFiles/config.cnf"
homeDir="/home/as2-streaming-user/MyFiles/"

for dbendpoint in "${dbendpoints[@]}"
do
    touch $configfile
    echo "[client]" > $configfile
    echo "host='$dbendpoint'" >> $configfile

    # Read-in db user name, write it to file
    read -sp "Enter a username for $dbendpoint: " DBUSER && printf "\n"
    echo "user='$DBUSER'" >> $configfile

    # Read-in password from prompt, write it to file and on success truncate the variable
    read -sp "Enter a password for $DBUSER: " PASSW && printf "\n"
    echo "password='$PASSW'" >> $configfile && export PASSW=''

    echo ""
    echo "Connecting to $dbendpoint with user $dbuser"

    for command in "${statusCommands[@]}"
    do
        echo "Executing command: $command"
        mysql                                       \
        --defaults-extra-file=$configfile           \
        --execute="$command"
        echo ""
    done
done



# rm -f $configfile
