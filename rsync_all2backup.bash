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

THE_SCRIPT=/Volumes/WorkSSD/work_roy/Scripts/rsync_4all.bash
LOG_FILE=/tmp/rsync_all2backup.log

function Help() {
cat  << EOF
    This script copies three data folders to a backup volume as follows:
      ${THE_SCRIPT} /Volumes/DataSSD/ /Volumes/BU_DataSSD/
      ${THE_SCRIPT} /Volumes/WorkSSD/ /Volumes/BU_WorkSSD/
      ${THE_SCRIPT} /Volumes/ScratchSSD/ /Volumes/BU_ScratchSSD/
    Options:
        -n)   dry run
        -l)   log output to ${LOG_FILE}
EOF
}

D_DRYRUN="n"
D_LOG="no"
# process options
while getopts ":hnl" opt; do
  case $opt in
    n) D_DRYRUN="y"
    ;;
    l) D_LOG="y"
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
fi

LOG_OPT=""
if [[ "$D_LOG" == "y" ]]; then
    LOG_OPT=" >> $LOG_FILE 2>&1"
fi


DATA_SRC=/Volumes/DataSSD/
DATA_DST=/Volumes/BU_DataSSD
bash_cmd="${THE_SCRIPT} ${DRYRUN_OPT} \"${DATA_SRC}\" \"${DATA_DST}\" ${LOG_OPT}"
TIME_START=$(date '+%Y-%m-%d %H:%M:%S')
echo "${TIME_START}: ${bash_cmd}"
time eval "$bash_cmd"

DATA_SRC=/Volumes/WorkSSD/
DATA_DST=/Volumes/BU_WorkSSD
bash_cmd="${THE_SCRIPT} ${DRYRUN_OPT} \"${DATA_SRC}\" \"${DATA_DST}\" ${LOG_OPT}"
TIME_START=$(date '+%Y-%m-%d %H:%M:%S')
echo "${TIME_START}: ${bash_cmd}"
time eval "$bash_cmd"

DATA_SRC=/Volumes/ScratchSSD/
DATA_DST=/Volumes/BU_ScratchSSD
bash_cmd="${THE_SCRIPT} ${DRYRUN_OPT} \"${DATA_SRC}\" \"${DATA_DST}\" ${LOG_OPT}"
TIME_START=$(date '+%Y-%m-%d %H:%M:%S')
echo "${TIME_START}: ${bash_cmd}"
time eval "$bash_cmd"


TIME_END=$(date '+%Y-%m-%d %H:%M:%S')
echo "${TIME_END}: Done"
