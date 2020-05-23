#!/bin/bash

SCRIPT_PATH=$(dirname ${BASH_SOURCE[0]})
PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Confirm this script is not currently running
for pid in $(pidof -x auto-syncoid.sh); do
    if [ $pid != $$ ]; then
        echo "Process already running"
        exit
    fi
done

# Config
declare -A SYNC_SRC_HOST
declare -A SYNC_SRC_PATH_PREFIX
declare -A SYNC_SRC_PATHS
source "${SCRIPT_PATH}/auto-syncoid.conf"

# Do the loop de loop!
for HOST in ${!SYNC_SRC_HOST[@]} ; do
    echo "Processing ${SYNC_SRC_HOST[$HOST]}..."
    for SRC_PATH in ${SYNC_SRC_PATHS[$HOST]} ; do
        echo "Syncing ${SYNC_SRC_PATH_PREFIX[$HOST]}${SRC_PATH} ==> ${SYNC_DST_PATH}/${SYNC_SRC_HOST[$HOST]}/${SRC_PATH}..."
        zfs create -p "${SYNC_DST_PATH}/${SYNC_SRC_HOST[$HOST]}/$(dirname ${SRC_PATH})"
        syncoid -r "${SYNC_SRC_PATH_PREFIX[$HOST]}${SRC_PATH}" "${SYNC_DST_PATH}/${SYNC_SRC_HOST[$HOST]}/${SRC_PATH}"
    done
done
