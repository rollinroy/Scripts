#!/bin/bash
# error handling
f () {
    errcode=$? # save the exit code as the first thing done in the trap function
    echo ">>>ERROR $errorcode"
    echo "     the command executing at the time of the error was"
    echo "     $BASH_COMMAND"
    echo "     on line ${BASH_LINENO[0]}"
    exit $errcode  # or use some other value or do return instead
}
function Help() {
cat  << EOF
    This script executes rsync from a src folder to a dst folder with two options:
        1) dry run (-n)
        2) do not delete files in dst folder not found in src fold (-N)

    Command syntax:
       rsync_4all [options] <src folder> <dst folder> where options include:
         1   option -N : rsync do not delete files in the dst folder that don't mach on local
         2   optoin -n : rsync dry run
         3   option -h : help
EOF
}
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
    \?) echo "*** ERROR: Invalid option -$OPTARG" >&2
    exit 1
    ;;
    :) echo "*** ERROR: Option -$OPTARG requires an argument." 1>&2
    exit 1
    ;;
  esac

done
#
# get the src folder
#
shift "$((OPTIND-1))"
if [ -z "$1" ]; then
    echo "*** ERROR: source folder is required"
    exit 1
fi
if [ -z "$2" ]; then
    echo "*** ERROR: destination folder is required"
    exit 1
fi

#
# src and optional dst
#
srcFolder=$1
dstFolder=$2
#
# check if src/dst exists
#
if [[ ! -d $srcFolder ]]; then
  echo "*** ERROR: source $srcFolder is not a directory"
  exit 1
fi
if [[ ! -d $dstFolder ]]; then
  read -p "Dst folder $dstFolder does not exist; 'y' to continue: " CONT
  if [[ "$CONT" != "y" ]]; then
    echo "*** ERROR: destination $dstFolder is not a directory"
    exit 1
  fi
  echo "rsync will create dst fold $dstFolder ..."
fi
# build the rsync command
if [[ $D_DRYRUN == "y" ]]; then
    RSYNC_N="-n"
else
    RSYNC_N=""
fi
if [[ $D_DELETE == "y" ]]; then
    RSYNC_DELETE="--delete"
else
    RSYNC_DELETE=""
fi

RSYNC_CMD="rsync -av ${RSYNC_DELETE} --exclude .Trashes --exclude .fseventsd --exclude .Temporary* --exclude .Spotlight* --exclude .DS_Store --exclude .meta*  --exclude .Document* ${RSYNC_N} \"$srcFolder\" \"$dstFolder\""
TIME_START=$(date '+%Y-%m-%d %H:%M:%S')
echo "${TIME_START}: >>> Copying $srcFolder to $dstFolder "
echo "${TIME_START}: ${RSYNC_CMD}"
time eval "$RSYNC_CMD"
