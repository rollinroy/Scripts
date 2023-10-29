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
    This script copies (rsync) a folder on the local host to an archive disk and
    folder. By default, newer files (or files no present on the local host) will
    not be deleted on the archive.  The archived disk must be already mounted.

    Command syntax:
       rsync_local2archive [options] <local folder> [<dst folder>] where options include:
         1   option -D : rsync delete files in the archive that don't mach on local
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
  dstFolder=/Volumes/ArchiveSSD/$srcBase
fi
if [[ ! -d $dstFolder ]]; then
  echo "Archive $dstFolder does not exist"
  exit 1
fi
#
# rsync local src folder to mounted image file
#
echo "`date` - rsync $srcFolder to $imageMountName ..."
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

RSYNC_CMD="rsync -av ${RSYNC_DELETE} --exclude .Trashes --exclude .fseventsd --exclude .Temporary* --exclude .Spotlight* --exclude .meta*  --exclude .Document* ${RSYNC_N} $srcFolder $dstFolder"
echo "$RSYNC_CMD"
time eval "$RSYNC_CMD"
hdiutil detach $imageMountName
