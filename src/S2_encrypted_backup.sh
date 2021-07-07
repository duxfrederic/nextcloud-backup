#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# distant server info (here relying on .ssh/config)
distanthost="ovh"
# distant directory
distantdir="/home/fred/Encrypted/"

# private ssh key authentificating us 
idfile="/home/fred/.ssh/id_rsa"

# where the backup is stored. We will copy from there
localbackupdirectory="/media/fred/sandisk" 
# where the distant directory should be mounted locally
localmount="/mnt/RemoteEncrypted/"

# name of the encrypted LUKFS image 
# (must be at the root of the distant directory)
imgfile="encrypted.img"
# where the encrypted image should be locally mounted
# (must as well be at the root of the distant directory)
localencrypted="Private"
# name of the local mapper 
localencryptedname="myEncryptedVolume"
# key file that decrypts the image
keyfile="/home/fred/mykey.keyfile"

mkdir -p $localmount
destdirectory="$localmount/$localencrypted"

# so, mount the distant filesystem here:
sshfs -o allow_other,default_permissions,IdentityFile=$idfile $distanthost:$distantdir $localmount
# decrypt the image 
cryptsetup luksOpen $localmount/$imgfile $localencryptedname --key-file $keyfile
# and mount it locally
mount /dev/mapper/$localencryptedname $destdirectory


# we are now ready to copy the backup over
rsync -a -H $(readlink $localbackupdirectory/nextcloud_backup/latest) $destdirectory/nextcloud_backup/.
rsync -a -H $(readlink $localbackupdirectory/nextcloud_varwwwhtml_backup/latest) $destdirectory/nextcloud_varwwwhtml_backup/.
cp $(ls -A $localbackupdirectory/nextcloud_database_backup | tail -n1) $destdirectory/nextcloud_database_backup/.


sleep 5

# final step, unmount everything. 
# close the LUKFS image:
echo "Unmounting $destdirectory"
umount $destdirectory
# disconnect from the sshfs process
dmsetup remove /dev/mapper/$localencryptedname
echo "Unmounting $localmount"
umount -l $localmount
