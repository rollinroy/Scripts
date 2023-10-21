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
    This script copies (rsync) a folder from an image file to a folder.  Command syntax:
       rsync_image [options] <src folder> <dst folder> where options include:
         1   option -i : image file base path (default: /Volumes/ImageBackups/)
         2   option -d : dst base path (default: /Volumes/)
         3   optoin -n : rsync dry run
         4   option -h : help
EOF
}
# input arguments and options
D_IPATH="/Volumes/ImageBackups/"
D_DPATH="/Volumes/"
D_DRYRUN=""
# process options
while getopts ":i:d:hn" opt; do
  case $opt in
    i) D_IPATH="$OPTARG"
    ;;
    n) D_DRYRUN="y"
    ;;
    d) D_DPATH="$OPTARG"
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
    echo "Two arguments (src/dst) are required"
    exit 1
fi
if [ -z "$2" ]; then
    echo "dst argument (2nd argument) is required"
    exit 1
fi

srcBaseName=$1
dstBaseName=$2
#
# copy src (an image file) to dst (local mounted file)
#
imageFile=$D_IPATH/${srcBaseName}.sparsebundle
dstFolder=$D_DPATH/${dstBaseName}/
srcFolder=/Volumes/$srcBaseName/
#
# check dst
#
if [[ ! -d $dstFolder ]]; then
    echo "dst folder $dstFolder does not exist"
    exit 1
fi
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
#
# check src folder is attached/mounted
#
if [[ ! -d $srcFolder ]]; then
    echo "src folder $dstFolder is not mounted from image file $imageFile"
    exit 1
fi
#
# rsync
#
echo "rsync $srcFolder to $dstFolder ..."
if [[ "$D_DRYRUN" == "y" ]]; then
    RSYNC_N="-n"
else
    RSYNC_N=""
fi
RSYNC_CMD="rsync -av --exclude .DS_Store --exclude .Trashes --exclude .fseventsd --exclude .TemporaryItems --exclude .Spotlight-V100 --exclude .meta* ${RSYNC_N} $srcFolder $dstFolder"
echo "$RSYNC_CMD"
time eval "$RSYNC_CMD"
hdiutil detach $srcFolder
