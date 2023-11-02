#!/bin/bash
# ONLY FROM rb-imac.local !!  copy from image backups to local volumes
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
    This script copies (rsync) an image file to a local folder.  Command syntax:
       rsync_image2local [options] <local folder> where options include:
         1   option -i : image file base name (default: rb-mbp-<local folder>)
         2   option -r : mounted image folder (/Volumes/ImageBackups)
         3   optoin -n : rsync dry run
         4   option -h : help

EOF
}
HNAME=`hostname`
if [[ "$HNAME" != "rb-imac.local" ]]  && [[ "$HNAME" != "rb-newmm.local" ]]; then
  echo "Script only runs on rb-imac.local or  rb-newmm.local (not $HNAME)"
  exit 1
fi
# input arguments and options
D_IFOLDER="/Volumes/ImageBackups"
D_IBASE=""
D_DRYRUN=""
D_IPBASE="rb-mbp"
# process options
while getopts ":i:d:hn" opt; do
  case $opt in
    i) D_IBASE="$OPTARG"
    ;;
    n) D_DRYRUN="y"
    ;;
    r) D_IFOLDER="$OPTARG"
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
    echo "local destination folder is required"
    exit 1
fi
#
# dst folder and check if it exists
#
dstFolder=$1
if [[ ! -d $dstFolder ]]; then
  echo "local source folder $dstFolder does net exist"
  exit 1
fi
baseName=$(basename "$dstFolder")
#
# src is the image file (/Volumes/ImageBackups/<imageBaseName>.sparsebundle) and
# folder (/Volumes/<imageBaseName>)
#
iBase=$D_IBASE
if [[ -z $iBase ]]; then
  iBase=$D_IPBASE-$baseName
fi
imageFile=/Volumes/ImageBackups/${iBase}.sparsebundle
srcFolder=/Volumes/${iBase}/
#
# check src attached/mounted
#
if [[ ! -d $srcFolder ]]; then
    echo "src folder $srcFolder is not mounted from image file; attaching image file $imageFile"
    if [[ ! -d $imageFile ]]; then
        echo "image file $imageFile does not exist"
        exit 1
    fi
    hdiutil attach $imageFile
fi
echo "Start rsync at `date` ..."
#
# rsync
#
echo "rsync $srcFolder to $dstFolder ..."
if [[ "$D_DRYRUN" == "y" ]]; then
    RSYNC_N="-n"
else
    RSYNC_N=""
fi
RSYNC_CMD="rsync -av --delete --exclude .Trashes --exclude .fseventsd --exclude .Temporary* --exclude .Spotlight* --exclude .meta*  --exclude .Document* ${RSYNC_N} $srcFolder $dstFolder"
echo "$RSYNC_CMD"
time eval "$RSYNC_CMD"
hdiutil detach $srcFolder
