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
function Help() {
cat  << EOF
    This script converts a wav file to be compatible with Boss RC500 loop station.
    The script first normalizes the wav file and then converts to 32-bit floating
    point bit depth with 2 channels.

    Command syntax:
       wav2rc500.bash -i <input wav> -o <outpu wav>

       options:
         1   option -i : input wav file (required)
         2   option -o : output wav file that is normalized, etc (required)
EOF
}
# process options
while getopts ":hi:o:" opt; do
  case $opt in
    h) Help
    exit 0
    ;;
    i) INPUT_WAV=$OPTARG
    ;;
    o) OUTPUT_WAV=$OPTARG
    ;;
    \?) echo ">>> wav2rc500 Error: Invalid option -$OPTARG" >&2
    Help
    exit 1
    ;;
    :) echo ">>> wav2rc500 Error: Option -$OPTARG requires two options -i and -o." 1>&2
    Help
    exit 1
    ;;
  esac
done
# get the remainder args
shift $((OPTIND -1))
if [[ ! -z $1 ]]; then
  echo ">>> wav2rc500 Error: Unsupported arguments given: $1"
  Help;
  exit 1
fi

if [[ -z ${INPUT_WAV} ]]; then
  echo ">>> wav2rc500 Error: input wav (-i) is required."
  Help;
  exit 1
fi

if [[ -z ${OUTPUT_WAV} ]]; then
  echo ">>> wav2rc500 Error: output wav (-o) is required."
  Help;
  exit 1
fi

if [ ! -f ${INPUT_WAV} ]; then
  echo "${INPUT_WAV} does not exists.";
  exit 1
fi

echo "Input wav file: ${INPUT_WAV}"
echo "Output wave file: ${OUTPUT_WAV}"
echo "Normalizing and convert to 2 channels ..."
# normalize and convert to 2 channels
python3 -m ffmpeg_normalize --loudness-range-target 10 -f -ac 2 ${INPUT_WAV} -o ${OUTPUT_WAV}
echo "Convert to 32-BIT float bits: ${OUTPUT_WAV}"
afconvert -d LEF32 ${OUTPUT_WAV} ${OUTPUT_WAV}
