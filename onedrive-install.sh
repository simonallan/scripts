#==========================================================
# Simple script to setup OneDrive Free Client on Linux Mint
# v1.0 Written by Simon Allan 2018-06-12
# https://github.com/skilion/onedrive
#==========================================================

# Vars
gitpath=/mnt/data/Git/


# Install dependencies
sudo apt install libcurl4-openssl-dev
sudo apt install libsqlite3-dev
sudo wget http://master.dl.sourceforge.net/project/d-apt/files/d-apt.list -O /etc/apt/sources.list.d/d-apt.list
sudo apt-get update && sudo apt-get -y --allow-unauthenticated install --reinstall d-apt-keyring
sudo apt-get update && sudo apt-get install dmd-compiler dub

# Install Onedrive integration
cd $gitpath
git clone https://github.com/skilion/onedrive.git
cd onedrive
make
sudo make install



#==========================================================================================

: <<'NOTES'

FIRST RUN
After installing the application you must run it at least once from the terminal to authorize it.

You will be asked to open a specific link using your web browser where you will have to login into 
your Microsoft Account and give the application the permission to access your files. After giving the 
permission, you will be redirected to a blank page. Copy the URI of the blank page into the application.


UNINSTALL
sudo make uninstall
# delete the application state
rm -rf .config/onedrive


CONFIGURATION
Configuration is optional. By default all files are downloaded in ~/OneDrive and only hidden files are skipped. If you want to change the defaults, you can copy and edit the included config file into your ~/.config/onedrive directory:

mkdir -p ~/.config/onedrive
cp ./config ~/.config/onedrive/config
nano ~/.config/onedrive/config

Available options:

sync_dir: directory where the files will be synced
skip_file: any files or directories that match this pattern will be skipped during sync.
Patterns are case insensitive. * and ? wildcards characters are supported. Use | to separate multiple patterns.

Note: after changing skip_file, you must perform a full synchronization by executing onedrive --resync


SELECTIVE SYNC
Selective sync allows you to sync only specific files and directories. To enable selective sync create a file 
named sync_list in ~/.config/onedrive. Each line of the file represents a relative path from your sync_dir. 
All files and directories not matching any line of the file will be skipped during all operations. 
Here is an example of sync_list:

  Backup
  Documents/latest_report.docx
  Work/ProjectX
  notes.txt

Note: after changing the sync list, you must perform a full synchronization by executing onedrive --resync


SHARED FOLDERS
Folders shared with you can be synced by adding them to your OneDrive. To do that open your Onedrive, go to the Shared files list, right click on the folder you want to sync and then click on "Add to my OneDrive".


ONEDRIVE SERVICE
If you want to sync your files automatically, enable and start the systemd service:

systemctl --user enable onedrive
systemctl --user start onedrive
To see the logs run:

journalctl --user-unit onedrive -f
Note: systemd is supported on Ubuntu only starting from version 15.04


NOTES

#========================================================================================

