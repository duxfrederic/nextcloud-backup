#!/bin/bash
# A script to perform incremental backups using rsync

set -o errexit
set -o nounset
set -o pipefail

readonly SOURCE_DIR="$1"
readonly BACKUP_DIR="$2"
readonly DATETIME="$(basename $SOURCE_DIR)"
readonly BACKUP_PATH="${BACKUP_DIR}/${DATETIME}"
readonly LATEST_LINK="${BACKUP_DIR}/latest"

mkdir -p ${BACKUP_DIR}

rsync -av --delete \
  "${SOURCE_DIR}/" \
  --link-dest "${LATEST_LINK}" \
  --no-perms --no-owner --no-group \
  --exclude=".cache" \
  "${BACKUP_PATH}/"

rm -rf ${LATEST_LINK}
ln -s ${BACKUP_PATH} ${LATEST_LINK}

