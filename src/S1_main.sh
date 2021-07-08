#!/bin/bash

# global settings
# (globals for the second step of the backup set in encrypted_backup.bash!)
localserver="rasp2" # Here I rely on my ~/.ssh/config which gives the address, port, private key and user to ssh.
localserverdirectory="/media/fred/sandisk" 

# nextcloud server details 
data="/mnt/bigdisk/nextcloud"
htmlfiles="/var/www/html/nextcloud"




if [[ $EUID -ne 0 ]]; then
   echo "This script must be ran as root"
   exit 1
fi

# first step, the backup to a local server.
./S1_backup_nextcloud.bash $localserver $localserverdirectory $data $htmlfiles 


# initializing the second step, we ssh into the localserver and create a file signaling
# that our local backup is ready to be copied over to the distant server. 
ssh $localserver "mkdir -p ~/.nextcloudbackup/; touch ~/.nextcloudbackup/localBackupDone"
