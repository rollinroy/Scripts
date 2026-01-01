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
    Options:
        -n)   dry run
        -l)   log output to ${LOG_FILE}
EOF
}

LOG="no"
D_DRYRUN="n"
# process options
while getopts ":hnl" opt; do
  case $opt in
    n) D_DRYRUN="y"
    ;;
    l) LOG="y"
    ;;
    h) Help
    exit
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    exit 1
    ;;
    :) echo "Option -$OPTARG requires an argument." 1>&2
    exit 1
    ;;
  esac

done
#
# get what's left
#
shift "$((OPTIND-1))"

DRYRUN_OPT=""
if [[ "$D_DRYRUN" == "y" ]]; then
    DRYRUN_OPT="-n"

LOG_OPT=""
if [[ "$LOG" == "y" ]]; then
    LOG_OPT=" >> $LOG_FILE 2>&1"
fi

bash_cmd="${THE_SCRIPT} ${DRYRUN_OPT} ${DATA_SRC} ${DATA_DST} ${LOG_OPT}"
TIME_START=$(date '+%Y-%m-%d %H:%M:%S')
echo "${TIME_START}: ${bash_cmd}"
time eval "$bash_cmd"
