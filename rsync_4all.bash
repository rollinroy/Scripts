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
function Help() {
cat  << EOF
    This script provides a general rsync command used by other local scripts.

    Command syntax:
       rsync_4all [options] <src folder> <dst folder> where options include:
         1   option -D : rsync delete files in the dst folder that don't mach on local
         2   optoin -n : rsync dry run
         3   option -h : help
EOF
}
# input arguments and options
D_DELETE=""
D_DRYRUN=""
# process options
while getopts ":hnD" opt; do
  case $opt in
    n) D_DRYRUN="y"
    ;;
    D) D_DELETE="y"
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
if [ -z "$1" ]; then
    echo "source folder is required"
    exit 1
fi
if [ -z "$2" ]; then
    echo "destination folder is required"
    exit 1
fi

#
# src and optional dst
#
srcFolder=$1
dstFolder=$2
#
# check src (required)
lchar="${srcFolder: -1}"
if [[ "$lchar" != "/" ]]; then
  srcFolder=$srcFolder/
fi
lchar="${dstFolder: -1}"
if [[ "$lchar" = "/" ]]; then
  dstFolder=${dstFolder::${#dstFolder}-1}
fi
# build the rsync command
if [[ "$D_DRYRUN" == "y" ]]; then
    RSYNC_N="-n"
else
    RSYNC_N=""
fi
if [[ "$D_DELETE" == "y" ]]; then
    RSYNC_DELETE="--delete"
else
    RSYNC_DELETE=""
fi

RSYNC_CMD="rsync -av ${RSYNC_DELETE} --exclude .Trashes --exclude .fseventsd --exclude .Temporary* --exclude .Spotlight* --exclude .DS_Store --exclude .meta*  --exclude .Document* ${RSYNC_N} $srcFolder $dstFolder"
TIME_START=$(date '+%Y-%m-%d %H:%M:%S')
echo "${TIME_START}: ${RSYNC_CMD}"
time eval "$RSYNC_CMD"
