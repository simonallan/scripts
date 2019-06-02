#!/bin/bash

# SET VARIABLES

# Different log types to look for
logtypearr=('out' 'err')

#filedate
filedate=`date +%Y%m%d_%H%M`
#findpath
findpath="/var/log/cruk_queue"



for l in "${logtypearr[@]}"
do
    # Regular Expression Type 
    # (Use 'find -regextype help' to see a list of supported types)
    regextype=posix-egrep
    # Regular Expression to test for
    regextest=".*/cruk_queue\.$l\.[0-9]"
    # Output archive file
    filenameout=cruk_queue.$l_$filedate.zip
    # Command to be executed by find
    findexec "zip $filenameout"
    
    echo "Searching $findpath for files matching $regextest...\n"
    findresults=find $findpath -regextype $regextype -regex $regextest #-exec $findexec {} \;
    
    echo Adding $findresults to Zip...
    unzip -l
done

