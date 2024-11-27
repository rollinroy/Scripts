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
    This script executes the following commands to copy all data to rb-newmmm:
      rsync_local2newmm.bash /Volumes/newmm_WorkSSD/
    Note: The rb-newmm volumes must be mounted (e.g., /Volumes/newmm_WorkSSD)
EOF
}
LOG_FILE=/tmp/rsync_work2newmm.log

DATA_SRC=/Volumes/WorkSSD
bash_cmd="/Volumes/WorkSSD/work_roy/Scripts/rsync_local2newmm.bash ${DATA_SRC} >> ${LOG_FILE} 2>&1"
TIME_START=$(date '+%Y-%m-%d %H:%M:%S')
echo "${TIME_START}: copy ${DATA_SRC} to rb-newmm (log: ${LOG_FILE})"
time eval "$bash_cmd"
