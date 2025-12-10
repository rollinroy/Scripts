#!/bin/bash
# error handling
f () {
    errcode=$? # save the exit code as the first thing done in the trap function
    echo ">>>Error $errorcode"
    echo "     the command executing at the time of the error was"
    echo "     $BASH_COMMAND"
    echo "     on line ${BASH_LINENO[0]}"
    exit $errcode  # or use some other value or do return instead
}
LOG_FILE=/tmp/rsync_vault2usb.log

DATA_SRC=/Volumes/DataSSD/Vaults/
DATA_DST=/Volumes/SS-Vaults/
THE_SCRIPT=/Volumes/WorkSSD/work_roy/Scripts/rsync_4all.bash

function Help() {
cat  << EOF
    This script copies ${DATA_SRC} to ${DATA_DST} via script:
        ${THE_SCRIPT}
EOF
}

# process options
while getopts ":hn" opt; do
  case $opt in
    n) D_DRYRUN="y"
    ;;
    h) Help
    exit
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    exit 1
    ;;
    :) echo "Invalid option: $OPTARG requires two arguments (dst/src)" 1>&2
    exit 1
    ;;
  esac

done
#
# get the src folder
#
shift "$((OPTIND-1))"
if [[ "$D_DRYRUN" == "y" ]]; then
    RSYNC_N="-n"
else
    RSYNC_N=""
fi

bash_cmd="${THE_SCRIPT} ${RSYNC_N} ${DATA_SRC} ${DATA_DST} >> ${LOG_FILE} 2>&1"
TIME_START=$(date '+%Y-%m-%d %H:%M:%S')
echo "${TIME_START}: ${bash_cmd}"
time eval "$bash_cmd"
