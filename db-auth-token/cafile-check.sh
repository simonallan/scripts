#!/bin/bash

outputDir="./output"
cafilesdir="./cafiles"

declare -a cafiles=(
    "global-bundle.pem"
    "mysql2-ssl-profile.pem"
)

if [ ! -d $outputDir ]; then
    mkdir $outputDir
fi

for cafile in "${cafiles[@]}"
do
    output="$outputDir/$cafile-output.txt"
    touch $output

    printf "Checking $cafile...\n" > $output
    printf "\nContents of certificate:\n" >> $output
    openssl x509 -in $cafilesdir/$cafile -noout -text >> $output

    printf "\nCertificate serial number:\n" >> $output
    openssl x509 -in $cafilesdir/$cafile -noout -serial >> $output

    printf "\nCertificate subject name:\n" >> $output
    openssl x509 -in $cafilesdir/$cafile -noout -subject >> $output

    printf "\nCertificate subject name in RFC2253 form:\n" >> $output
    openssl x509 -in $cafilesdir/$cafile -noout -subject -nameopt RFC2253 >> $output

    printf "\nCertificate subject name in oneline form (UTF8):\n" >> $output
    openssl x509 -in $cafilesdir/$cafile -noout -subject -nameopt oneline,-esc_msb >> $output

    printf "\nCertificate SHA1 fingerprint:\n" >> $output
    openssl x509 -sha1 -in $cafilesdir/$cafile -noout -fingerprint >> $output
done
