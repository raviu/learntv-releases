#!/usr/bin/env bash 

# Contributors: http://github.com/raviu/
# Last Updated: 27-06-2022

DATE_CMD="date"
if [[ $OSTYPE == 'darwin'* ]]; then
  DATE_CMD="gdate"
fi

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    "--help")       set -- "$@" "-h" ;;
    "--file")       set -- "$@" "-f" ;;
    "--timestamps") set -- "$@" "-t" ;;
    "--count")      set -- "$@" "-c" ;;
    "--output")     set -- "$@" "-o" ;;
    *)              set -- "$@" "$arg"
  esac
done

# Display help 
function display_help() {
    cat << EOF
thumbnail-extract v0.0.20 extracts PNG thumbnails from a given video file 

Usage (items inside [] are optional arguments):

./thumbnail-extract.sh -f|--file <file> [-t|--timestamps hh:mm:ss,hh:mm:ss  -c|--count <number>  -o|--output <jpg|png>]

Example

./thumbnail-extract.sh --file /home/learntv/2021-06-meditation-v2.ts --timesamps 00:01:10,01:04:20

Running across multiple videos in a directory: 
find . -iname "*.mp4" -type f -exec thumbnail-extract.sh -c 5 -f {} \;

Options:
-----------------------------
-f or --file        Video file path
-t or --timestamps  Comma separated list (no spaces) of timestamps to extract images from (example: 00:01:10,00:05:25 to extract two images: first from 1 minute 10 seconds into the video and second 5 minutes and 25 seconds into the video). 
-c or --count       Number of images to extract from randomised timestamps. Cannot be used in combinationg with -t|--timestamps. 
-o or --output      Output format of thumbnail. Has to be either jpg or png. If flag not present will default to jpg.
-h or --help        Display help
EOF
}

# Global Variables 
DEFAULT_COUNT=1
USE_TIMESTAMPS=false
OUTPUT_FORMAT=jpg

# Command flag and argument processing
while getopts  ":f:t:c:o:h" opt; do
    case $opt in 
        c)
            COUNT=$OPTARG 
            ;;
        f)
            FILE=$OPTARG 
            ;;
        t)
            IFS=',' read -a TIMESTAMPS <<< "$OPTARG" 
            echo "Extrating images from "${TIMESTAMPS[*]}""
            ;;
        o)
            OUTPUT_FORMAT=$OPTARG
            ;;
        h) 
            display_help
            exit 0 
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done 

# Validate Required Arguments 
shift "$(( OPTIND - 1 ))"
if [ -z "$FILE" ]; then
    echo "The -f argument is required. Please run ./thumbnail-extract.sh --help for help." >&2
    exit 1
fi

output_formats=(jpg png)

if [[ ! " ${output_formats[*]} " =~ " ${OUTPUT_FORMAT,,} " ]]; then
    echo "The -o or --output argument must be one of these: jgp or png. Please run ./thumbnail-extract.sh --help for help." >&2
    exit 1
fi

if [ ! -z "$TIMESTAMPS" ] && [ ! -z "$COUNT" ]; then
    echo "The -t|--timestamps argument cannot be used with the -c|--count. Only one of either -c or -t can be used at the same time. Please run ./thumbnail-extract.sh --help for help." >&2
    exit 1
fi

if [ -z "$COUNT" ] && [ -z "$TIMESTAMPS" ]; then
    COUNT=$DEFAULT_COUNT
fi

if [ -z "$COUNT" ] && [ ! -z "$TIMESTAMPS" ]; then 
    COUNT=${#TIMESTAMPS[@]}
    USE_TIMESTAMPS=true
fi


echo "${TIMESTAMPS[*]}"
echo $COUNT
for (( i=0; i<COUNT; i++ ))
do 
    if [ "$USE_TIMESTAMPS" = true ] ; then
        TS=${TIMESTAMPS[i]}
        echo "Extracting from timestamp $TS"
        #ffmpeg -skip_frame nokey -i file -vsync 0 -frame_pts true out%d.png
        ffmpeg -ss "$TS" -i "$FILE" -frame_pts true -frames:v 1 -qmin 1 -q:v 1 "$FILE""_thumb_"$i"_%d.$OUTPUT_FORMAT"
    else 
        DURATION=`ffmpeg -i "$FILE" 2>&1 | awk '/Duration/ {split($2,a,":");print a[1]*3600+a[2]*60+a[3]}'`
        RAND_SECONDS=`echo $[ $RANDOM % ${DURATION%.*} + 1 ]`
        TS=`$DATE_CMD -d@$RAND_SECONDS -u +%H:%M:%S`
        echo "Extracting from random timestamp $TS"
        ffmpeg -ss "$TS" -i "$FILE" -frame_pts true -frames:v 1 -qmin 1 -q:v 1 "$FILE""_thumb_"$i"_%d.$OUTPUT_FORMAT"
    fi
    
done
