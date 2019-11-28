#!/bin/bash
# Originally crafted by Julius Zaromskis
# Hacked by Simon Allan
# Backup rotation script

# N.B. This script does not create backups. It is designed to rotate backups created daily 
# into appropriate daily/weekly/monthly folders

# Email address to send warnings
emailaddress=simon.allan@cancer.org.uk

#Hostname of server we're running this script on
servername='LON-INF-LJRA01'

# Source folder where files are backed
source='/u01/atlassian/application-data/jira/export'

# Storage folder where to move backup files
# Must contain backup.monthly backup.weekly backup.daily folders
storage='/u01/atlassian/backups'

# Destination file names
date_daily=`date +"%Y-%m-%d"`
#date_weekly=`date +"%V sav. %m-%Y"`
#date_monthly=`date +"%m-%Y"`

# Get current month and week day number
month_day=`date +"%d"`
week_day=`date +"%u"`

# Optional check if source files exist. Email if failed.
if [ ! -f $source/*.zip ]; then
ls -l $source/ | mail $emailaddress -s "[backup rotation script] $servername Daily XML backup failed! Please check for missing files."
fi

# It is logical to run this script daily. We take files from source folder and move them to
# appropriate destination folder

# On first month day do
if [ "$month_day" -eq 1 ] ; then
  destination=$storage/backup.monthly/$date_daily
else
  # On saturdays do
  if [ "$week_day" -eq 6 ] ; then
    destination=$storage/backup.weekly/$date_daily
  else
    # On any regular day do
    destination=$storage/backup.daily/$date_daily
  fi
fi

# Move the files
mkdir $destination
mv -v $source/*.zip $destination

# daily - keep for 14 days
find $storage/backup.daily/ -maxdepth 1 -mtime +14 -type d -exec rm -rv {} \;

# weekly - keep for 60 days
find $storage/backup.weekly/ -maxdepth 1 -mtime +60 -type d -exec rm -rv {} \;

# monthly - keep for 300 days
find $storage/backup.monthly/ -maxdepth 1 -mtime +300 -type d -exec rm -rv {} \;