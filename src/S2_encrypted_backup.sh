#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source $SCRIPT_DIR/backup.config

if [ ! -f "$SIGNAL_FILE" ] 
then 
	echo "$SIGNAL_FILE does not exist - nothing to do."
	exit
else
	echo "$SIGNAL_FILE exists - proceeding with the backup."
	rm $SIGNAL_FILE
fi


mkdir -p $localmount
destdirectory="$localmount/$localencrypted"

# so, mount the distant filesystem here:
sshfs -o allow_other,default_permissions,IdentityFile=$idfile $distanthost:$distantdir $localmount
# decrypt the image 
/sbin/cryptsetup luksOpen $localmount/$imgfile $localencryptedname --key-file $keyfile
# and mount it locally
mount /dev/mapper/$localencryptedname $destdirectory
mkdir -p $destdirectory/nextcloud_backup
mkdir -p $destdirectory/nextcloud_varwwwhtml_backup
mkdir -p $destdirectory/nextcloud_database_backup



# we are now ready to copy the backup over
$SCRIPT_DIR/S2_backup_single_dir.bash $(readlink $localbackupdirectory/nextcloud_backup/latest) $destdirectory/nextcloud_backup
echo "Done copying the data"
$SCRIPT_DIR/S2_backup_single_dir.bash $(readlink $localbackupdirectory/nextcloud_varwwwhtml_backup/latest) $destdirectory/nextcloud_varwwwhtml_backup
echo "Done copying the html"
cp $localbackupdirectory/nextcloud_database_backup/$(ls -A $localbackupdirectory/nextcloud_database_backup | tail -n1) $destdirectory/nextcloud_database_backup/.
echo "Done copying the database dump"
echo 
echo "waiting for a few seconds before unmounting"
sleep 5

# final step, unmount everything. 
# close the LUKFS image:
echo "Unmounting $destdirectory"
umount -l $destdirectory
# disconnect from the sshfs process
/sbin/dmsetup remove /dev/mapper/$localencryptedname
echo "Unmounting $localmount"
umount -l $localmount
