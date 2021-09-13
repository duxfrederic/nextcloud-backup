#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source $SCRIPT_DIR/backup.config

mkdir -p $localmount
destdirectory="$localmount/$localencrypted"

# so, mount the distant filesystem here:
sshfs -o allow_other,default_permissions,IdentityFile=$idfile $distanthost:$distantdir $localmount
# decrypt the image 
/sbin/cryptsetup luksOpen $localmount/$imgfile $localencryptedname --key-file $keyfile
# and mount it locally
mount /dev/mapper/$localencryptedname $destdirectory


echo '#######################  is there space left on the device? #################'
df -h $destdirectory
echo '#############################################################################'














