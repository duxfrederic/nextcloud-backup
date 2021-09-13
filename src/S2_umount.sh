#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source $SCRIPT_DIR/backup.config
destdirectory="$localmount/$localencrypted"

# final step, unmount everything. 
# close the LUKFS image:
echo "Unmounting $destdirectory"
umount -l $destdirectory
# disconnect from the sshfs process
/sbin/dmsetup remove /dev/mapper/$localencryptedname
echo "Unmounting $localmount"
umount -l $localmount
