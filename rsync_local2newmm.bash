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
    This script copies (rsync) a folder on the local host to a folder on
    the rb-newmm.  The remote folder must be already mounted via finder.

    Command syntax:
    rsync_local2newmm [options] <local folder> [<dst folder>] where options include:
      1   option -N : rsync dO not delete files in the archive that don't match on local
      2   optoin -n : rsync dry run
      3   option -h : help
EOF
}
# script name and date
SCRIPTNAME=$(basename "$0")
# input arguments and options
D_DELETE="y"
D_DRYRUN=""
# process options
while getopts ":hnN" opt; do
  case $opt in
    n) D_DRYRUN="y"
    ;;
    N) D_DELETE="n"
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
    echo "local source folder is required"
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
if [[ ! -d $srcFolder ]]; then
  echo "local source folder $srcFolder does net exist"
  exit 1
fi
#
# src base name
#
srcBase=$(basename "$srcFolder")
#
# dst folder
#
if [ -z $dstFolder ]; then
  dstFolder=/Volumes/newmm_$srcBase
fi
if [[ ! -d $dstFolder ]]; then
  echo "Backup $dstFolder does not exist"
  exit 1
fi
#
# rsync local src folder to backup
#
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
TIME_START=$(date '+%Y-%m-%d %H:%M:%S')
echo ">>> Executing $SCRIPTNAME at $TIME_START - rsync $srcFolder to $dstFolder ..."
RSYNC_CMD="rsync -av ${RSYNC_DELETE} --exclude .Trashes --exclude .fseventsd --exclude .Temporary* --exclude .Spotlight* --exclude .meta*  --exclude .Document* ${RSYNC_N} $srcFolder $dstFolder"
echo "$RSYNC_CMD"
time eval "$RSYNC_CMD"
TIME_END=$(date '+%Y-%m-%d %H:%M:%S')
echo ">>> $SCRIPTNAME: started at $TIME_START and finished at $TIME_END"
