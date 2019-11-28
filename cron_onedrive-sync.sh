#!/bin/sh

# Brief script to automate OneDrive Resyncs with CRON
# Written by Simon Allan 2018-06-20
# Version 1.0

# Forget the last saved state, perform a full sync
cd /home/allan05/data/OneDrive
onedrive --resync
