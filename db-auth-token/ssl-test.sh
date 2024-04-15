#!/bin/bash


# SSL-MODE Modes
# ==================

# DISABLED
# Establish an unencrypted connection. This is like the legacy --ssl=0 option or its synonyms (--skip-ssl, --disable-ssl).

# PREFERRED
# Establish an encrypted connection if the server supports encrypted connections, falling back to an unencrypted connection
# if an encrypted connection cannot be established. This is the default if --ssl-mode is not specified.

# Connections over Unix socket files are not encrypted with a mode of PREFERRED. To enforce encryption for Unix socket-file
# connections, use a mode of REQUIRED or stricter. (However, socket-file transport is secure by default, so encrypting a
# socket-file connection makes it no more secure and increases CPU load.)

# REQUIRED
# Establish an encrypted connection if the server supports encrypted connections. The connection attempt fails if an
# encrypted connection cannot be established.

# VERIFY_CA
# Like REQUIRED, but additionally verify the server Certificate Authority (CA) certificate against the configured CA
# certificates. The connection attempt fails if no valid matching CA certificates are found.

# VERIFY_IDENTITY
# Like VERIFY_CA, but additionally perform host name identity verification by checking the host name the client uses
# for connecting to the server against the identity in the certificate that the server sends to the client:

# As of MySQL 5.7.23, if the client uses OpenSSL 1.0.2 or higher, the client checks whether the host name that it uses for
# connecting matches either the Subject Alternative Name value or the Common Name value in the server certificate. Host
# name identity verification also works with certificates that specify the Common Name using wildcards.

# Otherwise, the client checks whether the host name that it uses for connecting matches the Common Name value in the
# server certificate.

# The connection fails if there is a mismatch. For encrypted connections, this option helps prevent
# man-in-the-middle attacks. This is like the legacy --ssl-verify-server-cert option.
#
# From: https://dev.mysql.com/doc/refman/8.0/en/connection-options.html#encrypted-connection-options


declare -a dbendpoints=(
    'ofrfwsapplicationintegratipplicationintegrationproxya9bc99b4.proxy-cijbd5cnppmo.eu-west-2.rds.amazonaws.com'
)

declare -a sslmodes=(
    DISABLED
    PREFERRED
    REQUIRED
)

declare -a verifycas=(
    VERIFY_CA
    VERIFY_IDENTITY
)

configfile="/home/as2-streaming-user/MyFiles/config.cnf"
cafilepath="/home/as2-streaming-user/MyFiles/"

declare -a cafiles=(
    global-bundle.pem
    mysql2-ssl-profile.pem
)

dbuser="proxy"

# Get secure password at interactive command line


for dbendpoint in "${dbendpoints[@]}"
do
    touch $configfile
    echo "[client]" > $configfile
    echo "user='$dbuser'" >> $configfile
    echo "host='$dbendpoint'" >> $configfile

    # Read-in password from prompt, write it to file and if successful truncate variable
    read -sp "Enter a password for $dbuser: " PASSW && printf "\n"
    echo "password='$PASSW'" >> $configfile && export PASSW=''

    echo ""
    echo "Connecting to $dbendpoint with user $dbuser"
    echo executing command "status; | grep SSL"

    for sslmode in "${sslmodes[@]}"
    do
        echo "Trying SSL-Mode $sslmode"
        mysql                                       \
        --defaults-extra-file=$configfile           \
        --ssl-mode=$sslmode                         \
        --enable-cleartext-plugin                   \
        --execute "status;" | grep SSL
    done

    for cafile in "${cafiles[@]}"
    do
        echo ""
        echo "Checking CA File $cafile"

        for verifyca in "${verifycas[@]}"
        do
            echo "verifying $cafile with $verifyca"
            mysql                                       \
            --defaults-extra-file=$configfile           \
            --ssl-mode=$verifyca                        \
            --ssl-ca=$cafile             			    \
            --enable-cleartext-plugin                   \
            --execute "status;" | grep SSL
        done
    done
done

rm -f $configfile
