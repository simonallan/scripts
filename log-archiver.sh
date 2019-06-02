#!/bin/bash

# SET VARIABLES

# Different log types to look for
logtypearr=('out' 'err')

#filedate
#filedate=`date +%Y%m%d-%H%M`
#filedate=`date +%Y%m%d-%H%M`
#findpath
findpath="/var/log/cruk_queue"



for l in "${logtypearr[@]}"
do
    # Regular Expression Type 
    # (Use 'find -regextype help' to see a list of supported types)
    regextype=posix-egrep
    # Regular Expression to test for
    regextest=".*/cruk_queue\.${l}\.[0-9]"
    # Output archive file
    filenameout=cruk_queue-$l-$filedate.zip
    
    # Test if target files exist
    echo .
    echo "Checking if $l variant files exist:"
    findresults=$(find $findpath -regextype $regextype -regex $regextest)

    if [ ! -z "$findresults" ]
    then
        echo "Files Found:"
        find $findpath -regextype $regextype -regex $regextest -exec zip "$findpath/$filenameout" {} +
        echo "Checking ZIP contents:"
        unzip -l $findpath/$filenameout
        echo .
        #echo Commencing Cleanup. Press N to cancel, Y to delete.
        #find /var/log/cruk_queue -regextype posix-egrep -regex ".*/cruk_queue\.${l}\.[0-9]" -exec rm -i {} +
    else
        echo "No matching files. Exiting."
    fi
done

