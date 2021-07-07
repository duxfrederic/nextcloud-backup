#!/bin/bash
# A script to perform incremental backups using rsync

set -o errexit
set -o nounset
set -o pipefail

readonly SOURCE_DIR="$1"
readonly BACKUP_DIR="$2"
readonly REMOTE_COMP="$3"
readonly DATETIME="$(date '+%Y-%m-%d_%H-%M-%S')"
readonly BACKUP_PATH="${BACKUP_DIR}/${DATETIME}"
readonly LATEST_LINK="${BACKUP_DIR}/latest"

ssh ${REMOTE_COMP} "mkdir -p ${BACKUP_DIR}"

rsync -av --delete \
  "${SOURCE_DIR}/" \
  --link-dest "${LATEST_LINK}" \
  --no-perms --no-owner --no-group \
  --exclude=".cache" \
  "${REMOTE_COMP}:${BACKUP_PATH}"

ssh ${REMOTE_COMP} "rm -rf ${LATEST_LINK}"
ssh ${REMOTE_COMP} "ln -s ${BACKUP_PATH} ${LATEST_LINK}"

