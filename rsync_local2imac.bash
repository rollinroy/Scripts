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
    the iMac.  The remote folder must be already mounted via finder.

    Command syntax:
       rsync_local2imac [options] <local folder> <imac folder> where options include:
         1   optoin -n : rsync dry run
         2   option -h : help
EOF
}
# input arguments and options
D_DRYRUN=""
# process options
while getopts ":i:r:hn" opt; do
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
# get the dst/src arguments
#
shift "$((OPTIND-1))"
if [ -z "$1" ]; then
    echo "local source folder is required"
    exit 1
fi
if [ -z "$2" ]; then
    echo "imac dst folder is required"
    exit 1
fi
srcFolder=$1
dstFolder=$2

#
# src folder and check if it exists
#
srcFolder=$1
lchar="${srcFolder: -1}"
if [[ "$lchar" != "/" ]]; then
  srcFolder=$srcFolder/
fi
if [[ ! -d $srcFolder ]]; then
  echo "local source folder $srcFolder does net exist"
  exit 1
fi
#
# dst folder
#
if [ -z $dstFolder ]; then
  dstFolder=/Volumes/$dstFolder
fi
if [[ ! -d $dstFolder ]]; then
  echo "imac $dstFolder does not exist"
  exit 1
fi

#
# rsync local src folder to mounted image file
#
echo "`date` - rsync $srcFolder to $dstFolder ..."
if [[ "$D_DRYRUN" == "y" ]]; then
    RSYNC_N="-n"
else
    RSYNC_N=""
fi
RSYNC_CMD="rsync -av --delete --exclude .Trashes --exclude .fseventsd --exclude .Temporary* --exclude .Spotlight* --exclude .meta*  --exclude .Document* ${RSYNC_N} $srcFolder $dstFolder"
echo "$RSYNC_CMD"
time eval "$RSYNC_CMD"
