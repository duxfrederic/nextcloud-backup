#!/bin/bash
# globals for the first step of the backup (local server)
remoteComp=$1
remoteDir=$2
data=$3
htmlfiles=$4

# maintenance mode
sudo -u www-data php $htmlfiles/occ maintenance:mode --on
echo "Activated maintenance mode"



SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

DATETIME="$(date '+%Y-%m-%d_%H-%M-%S')"

# backup the data (very long)
$SCRIPT_DIR/S1_backup_single_dir_ssh.bash $data/ ${remoteDir}/nextcloud_backup ${remoteComp} $DATETIME
# backup the files (m'okay long)
$SCRIPT_DIR/S1_backup_single_dir_ssh.bash $htmlfiles/ ${remoteDir}/nextcloud_varwwwhtml_backup ${remoteComp} $DATETIME
# backup the database by dumping to tmp, then scp. 
# (you can change the /tmp thing if not secure enough for your need)
databasefilename="nextcloud-sqlbkp_$DATETIME"
sudo -u postgres pg_dump nextcloud -f /tmp/${databasefilename} 
ssh ${remoteComp} "mkdir -p ${remoteDir}/nextcloud_database_backup/"
scp /tmp/${databasefilename} ${remoteComp}:${remoteDir}/nextcloud_database_backup/.
rm /tmp/${databasefilename}


# disable maintenance mode
sudo -u www-data php $htmlfiles/occ maintenance:mode --off
echo "Done"
