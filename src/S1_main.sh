#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be ran as root"
   exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source $SCRIPT_DIR/backup.config



# first step, the backup to a local server.
$SCRIPT_DIR/S1_backup_nextcloud.bash $localserver $localserverdirectory $data $htmlfiles 


# initializing the second step, we ssh into the localserver and create a file signaling
# that our local backup is ready to be copied over to the distant server. 
ssh $localserver "mkdir -p ~/.nextcloudbackup/; touch $SIGNAL_FILE"
