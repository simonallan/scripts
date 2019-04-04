#!/bin/bash
#set -o xtrace

#servarr=('10227' '10228' '10229' '15242' '15243' '15244' '15245')
servarr=('10227' '10228')
datearr=('20190311' '20190312' '20190313' '20190314')
creds="~/.ssh/allan05-acquia su2c.prod@web-$s.prod.hosting.acquia.com"


#su2c@web-10227:/$ find /var/log/sites/su2c/logs/web-10227/ -name access.log-* -mtime -4 -mtime +1
#/var/log/sites/su2c/logs/web-10227/access.log-20190325.gz
#/var/log/sites/su2c/logs/web-10227/access.log-20190326.gz

logpath='/var/log/sites/su2c/logs/web-10227/'
destpath='/home/allan05/data/Logs/su2c-gbbo-stats'


for s in "${servarr[@]}"
do
  #'ssh="ssh -oStrictHostKeyChecking=no -i ~/.ssh/allan05-acquia su2c.prod@web-$s.prod.hosting.acquia.com"
  # $ssh logfiles=$(find $logpath -name access.log-* -mtime -4 -mtime +0) | echo $logfiles
  logpath="/var/log/sites/su2c/logs/web-$s"
  destpath="/home/allan05/data/logs/su2c-gbbo-stats/$s"



  for d in "${datearr[@]}"
  do
    cd /home/allan05/data/logs/su2c-gbbo-stats/
    mkdir $destpath
    scp -i $creds:$logpath/access.log-$d.gz $destpath
  done
done
