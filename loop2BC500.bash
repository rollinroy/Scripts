#!/bin/bash
# error handling
f () {
    errcode=$? # save the exit code as the first thing done in the trap function
    SFILE="$(basename "$0")"
    echo ">>> Error in ${SFILE} ${errorcode}"
    echo "     the command executing at the time of the error was"
    echo "     $BASH_COMMAND"
    echo "     on line ${BASH_LINENO[0]}"
    exit $errcode  # or use some other value or do return instead
}
trap f ERR
count=98
#LOOP_DIR=/Volumes/ScratchSSD/roy/LOOP/JAMMAN/
LOOP_DIR=/Volumes/NO_NAME/JAMMAN/
BC50O_DIR=/Volumes/ScratchSSD/roy/LOOP/BC500/ROLAND/WAVE/
fCount=0
# The input LOOP.wav was generated from JAMMAN and not compatible with Boss
# RC 500.  The following must be done:
#    1. normalize volume
#    2. convert to channel
#    3. convert to 32-bit floating point
for file in $(ls "$LOOP_DIR"/ | sort); do
  #for file in "${LOOP_DIR}"/*; do
  LOOP_FILE=$LOOP_DIR$file/LOOP.wav
  fCount=$((fCount+1))
  printf -v ffCount "%03d" $fCount
  OUT_DIR=${BC50O_DIR}${ffCount}_1/
  LOOP_NEW=${OUT_DIR}/LOOP.wav
  echo "Input LOOP file: ${LOOP_FILE}"
  echo "Normalized LOOP file: ${LOOP_NEW}"
  if [ -f ${LOOP_FILE} ]; then
    # normalize and convert to 2 channels
    python3 -m ffmpeg_normalize --loudness-range-target 10 -f -ac 2 ${LOOP_FILE} -o ${LOOP_NEW}
    echo "32-BIT float output file: ${LOOP_NEW}"
    afconvert -d LEF32 ${LOOP_NEW} ${LOOP_NEW}
  else
    echo "*** WARNING: no file ${LOOP_FILE}"
fi

done
