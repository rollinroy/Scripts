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

LOG_FILE=/tmp/rsync_local2archive.log
THE_SCRIPT=/Volumes/WorkSSD/work_roy/Scripts/rsync_4all.bash

function Help() {
cat  << EOF
    This script archives a src folder to an archive folder via script:
        ${THE_SCRIPT} SRC_Folder Archive_Folder
    As an archive, it does not delete files in the archive that are newer or
    does not exist in the src folder.

    Options:
        -n)   dry run
        -D)   delete newer files in archive
        -l)   log output to ${LOG_FILE}
EOF
}
# input arguments and options
D_DELETE="n"
D_DRYRUN=""
D_LOG=""
# process options
while getopts ":hlnD" opt; do
  case $opt in
    n) D_DRYRUN="y"
    ;;
    D) D_DELETE="y"
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
#
# get the src folder
#
if [ -z "$1" ]; then
    echo "local source folder is required"
    exit 1
fi
if [ -z "$2" ]; then
    echo "archive destination folder is required"
    exit 1
fi
#
# src and optional dst
#
srcFolder=$1
dstFolder=$2

DRYRUN_OPT=""
if [[ $D_DRYRUN == "y" ]]; then
    DRYRUN_OPT="-n"
fi

NODELETE_OPT="-N"
if [[ "$D_DELETE" == "y" ]]; then
    NODELETE_OPT=""
fi

LOG_OPT=""
if [[ $D_LOG == "y" ]]; then
    LOG_OPT=" >> $LOG_FILE 2>&1"
fi

bash_cmd="${THE_SCRIPT} ${NODELETE_OPT} ${DRYRUN_OPT} \"${srcFolder}\" \"${dstFolder}\" ${LOG_OPT}"
TIME_START=$(date '+%Y-%m-%d %H:%M:%S')
echo "${TIME_START}: ${bash_cmd}"
time eval "$bash_cmd"
