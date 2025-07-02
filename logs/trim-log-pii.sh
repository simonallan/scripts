#!/bin/bash
# Another crappy scrpt, this one purges a massive log file of PII and shrinks it


hosts=(vmd17 vmd18 vmd19 arbiter)
for host in "${hosts[@]}"; do

backupfile="mongodb.$host.log"
infile="mongodb.$host.trim.log"
logfile="trim.log"


# Payment data to be scrubbed of PII, but keep the essence of the log entry
declare -a SedArray
IFS=""
SedArray[1]="WorldPay\/DTD WorldPay PaymentService v1.*Error updating transaction Worldpay error:\[@code=5\]"
SedArray[2]="WRITE.*proddonationdb\.payments.*status:..\(Pending\|Successful\|Captured\|Failed\|Cancelled\|Refunded\)"
SedArray[3]="WorldPay\/DTD WorldPay PaymentService v1.*\.\.\.., \(AVS result\|CVS result\|CSV result\|EchoData\|Last capture\)"
SedArray[4]="WorldPay\/DTD WorldPay PaymentService v1.*\.\.\.., \(Request XML\|Response XML\|SessionCookie\|WorldPayCode\|}, successful\)"
SedArray[5]="WorldPay\/DTD WorldPay PaymentService v1.*\.\.\.., \(name\|description\|last event\|message\|Risk score\|Pa Res\|MD\|Capture\)"
SedArray[6]="WorldPay\/DTD WorldPay PaymentService v1.*\.\.\.. \(Request XML\|}, successful\)"
SedArray[7]="\(WRITE\|COMMAND.*\[conn2594242\]\).*proddonationdb\.\(orders\|recurrent-payments\)"
#SedArray[13]="\(firstname\|lastname\)"

if test -f "$logfile"; then
        echo .
	echo Log file found
else
        touch $logfile
	echo "No log file found. Creating $logfile..."
fi

# output to console and to logfile
exec > >(tee $logfile) 2>&1

# Rotate file to be processed
if test -f "$infile"; then
	echo Old input file found. Deleting...
	rm -f $infile && echo Done.
	#rm -f -i $infile && echo Done.
	echo Creating new input file $infile...
	cp $backupfile $infile && echo Done.
else
	echo No input files found. Creating $infile...
	cp $backupfile $infile && echo Done.
fi

echo .
echo Starting file sizes:
ls -hal $backupfile && ls -hal $infile

echo .
echo "Purging loglines matching the following terms"
for pii in ${SedArray[@]}; do
        echo Search term: $pii
done

echo .
echo Trimming log file...
for pii in ${SedArray[@]}; do
	echo Trimming $pii
	comment="# Line removed. Criteria: $pii"
	
	# Find and replace lines in log file that match RegExes in array
        sed -i "/$pii/c\\$comment" $infile	

        # Count how many lines were replaced
	grep -E $comment $infile --count
	ls -hal $backupfile && ls -hal $infile
	echo .
done

echo .
echo Trimming Complete.
echo Calculating stats:
totlines=$(wc -l $infile)
updlines=$(grep "Line removed. Criteria" $infile --count)

echo "$totlines"
echo "$updlines lines redacted"
echo "Please verify the results"

echo Quick Test

fname=$(grep 'firstname' $infile --count)
echo Count for 'firstname' $fname
pmail=$(grep 'email' $infile | grep -v 'email_templates\|email_provider' --count)
echo Count for 'email' $pmail
baddr=$(grep 'billingaddress' $infile --count)
echo Count for 'billingaddress' $baddr

done

