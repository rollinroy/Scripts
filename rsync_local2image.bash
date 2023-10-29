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
    This script copies (rsync) a folder on the local host to an an image file on
    a remote host. The image file resides in a folder on the remote host that
    must be already mounted.

    Command syntax:
       rsync_image_backup [options] <local folder> where options include:
         1   option -i : image file base name (default: rb-mbp-<local folder>)
         2   option -r : remote mounted image folder (/Volumes/ImageBackups)
         3   optoin -n : rsync dry run
         4   option -h : help
EOF
}
# input arguments and options
D_IFOLDER="/Volumes/ImageBackups"
D_IFILE=""
D_DRYRUN=""
# process options
while getopts ":i:r:hn" opt; do
  case $opt in
    i) D_IFILE="$OPTARG"
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
    echo "local source folder is required"
    exit 1
fi
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
# src base name
#
srcBase=$(basename "$srcFolder")

#
# create the image file name
#
imageBaseName=$D_IFILE
if [[ -z "$D_IFILE" ]]; then
  imageBaseName=rb-mbp-$srcBase
fi
#
# verify file exists
#
fullImageName=$D_IFOLDER/${imageBaseName}.sparsebundle
if [[ ! -d $fullImageName ]]; then
  echo "image file $fullImageName does not exist"
  exit 1
fi
#
# if necessary attach the image file
#
imageMountName=/Volumes/$imageBaseName
if [[ ! -d $imageMountName ]]; then
  # attach the image
  hdiutil attach $fullImageName
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
RSYNC_CMD="rsync -av --delete --exclude .Trashes --exclude .fseventsd --exclude .Temporary* --exclude .Spotlight* --exclude .meta*  --exclude .Document* ${RSYNC_N} $srcFolder $imageMountName"
echo "$RSYNC_CMD"
time eval "$RSYNC_CMD"
hdiutil detach $imageMountName
