#!/usr/bin/env bash 

# Contributors: http://github.com/raviu/
# Last Updated: 23-09-2021
# Version: v0.0.15

# Global Variables with defaults 
VBR="2500k"                                   
FPS="30"                                       
QUAL="medium"                                  
YOUTUBE_URL="rtmp://a.rtmp.youtube.com/live2"  
START_TIME="04:59:59"

DATE_CMD="date"
if [[ $OSTYPE == 'darwin'* ]]; then
  DATE_CMD="gdate"
fi

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    "--help")           set -- "$@" "-h" ;;
    "--m3u")            set -- "$@" "-m" ;;
    "--quality")        set -- "$@" "-q" ;;
    "--bitrate")        set -- "$@" "-b" ;;
    "--fps")            set -- "$@" "-f" ;;
    "--key")            set -- "$@" "-k" ;;
    "--start")          set -- "$@" "-s" ;;
    *)                  set -- "$@" "$arg"
  esac
done

# Display help 
function display_help() {
    cat << EOF
youtube-live.sh v0.0.15 streams m3u playlist file to YouTube

Usage (items inside [] are optional arguments):

./youtube-live.sh.sh -m|--m3u <file> -k|--key <YouTube Key> [-q|--quality <quality string> -b|--bitrate <variable bit rate> -f|--fps <frames per second> -s|--start <start time in HH:mm:ss>]

Example

./youtube-live.sh --m3u /home/learntv/dharmavahini/2021/09/sep-4.m3u -k YOUTUBE_KEY

Options:
-----------------------------
-m or --m3u         M3U playlist file path. This argument is required. 
-k or --key         YouTube streaming key. This argument is required. 
-q or --quality     Quality string like medium. This is optional and will default to medium. 
-b or --bitrate     Variable bitrate. This is optional and will default to 2500k.
-f or --fps         Frames per second. This is optional and will default to 30.
-s or --start       Specify the start time of the playlist in 24 hour format HH:mm:ss. Defaults to 05:00:00 (5AM)
-h or --help        Display help
EOF
}

# Command flag and argument processing
while getopts  ":m:q:b:f:k:s:h" opt; do
    case $opt in 
        m)
            M3U=$OPTARG 
            PLAYLIST_DAY=`basename $OPTARG | cut -d'-' -f2 | cut -d'.' -f1`
            ;;
        q)
            QUAL=$OPTARG 
            ;;
        b)
            VBR=$OPTARG 
            ;;
        f)
            FPS=$OPTARG 
            ;;
        k)
            KEY=$OPTARG 
            ;;
        s)
            START_TIME=$OPTARG
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
if [ -z "$KEY" ] || [ -z "$M3U" ]; then
    echo "The -k and -m arguments are both required. Please run ./youtube-live.sh --help for help." >&2
    exit 1
fi                                  

PLAYLIST_START_TIME=$($DATE_CMD --date "`$DATE_CMD +'%Y'`-`$DATE_CMD +'%m'`-$PLAYLIST_DAY $START_TIME" "+%s")
echo "PLAYLIST_START_TIME `$DATE_CMD -d @$PLAYLIST_START_TIME`"

PLAYCURSOR=$PLAYLIST_START_TIME
CURRENT_TIME=`$DATE_CMD +%s`
echo "CURRENT_TIME `$DATE_CMD -d @$CURRENT_TIME`"

if [[ $CURRENT_TIME -lt $((PLAYCURSOR)) ]]; then 
    echo "The playlist $M3U cannot be played before `$DATE_CMD -d @$PLAYCURSOR`! Are you trying to stream it before scheduled start time?"
    exit 1
fi

KEEP_SKIPPING=1
SKIP_NEXT=0
while read -r line; do

    CURRENT_TIME=`$DATE_CMD +%s`

    if [[ "$line" == "#EXTM3U" ]]; then
        continue
    elif [[ "$line" == \#* ]]; then 
        video_start_time=`echo $line | awk -v delimeter="START_TIME:" '{split($0,a,delimeter)} END{print a[2]}'`
        duration_seconds=`echo $line | awk -v delimeter="START_TIME:" '{split($0,a,delimeter)} END{print a[1]}' | cut -d ':' -f2 | cut -d',' -f1`
        echo "Item Starts $video_start_time"
        echo "Item Ends `$DATE_CMD -d @$((PLAYCURSOR+duration_seconds))`"
    else 
        if [[ "$SKIP_NEXT" == "1" ]]; then 
            SKIP_NEXT=0
            echo "Skipping $line"
            echo "=++++++========+++++======++++++========+++++======++++++========+++++======++++++========+++++====="  
            continue
        else 
            echo "Playing $line with skip seconds $skip_seconds"

            ffmpeg \
            -nostdin -y -re -i "$line" \
            -ss $skip_seconds \
            -vcodec libx264 -pix_fmt yuv420p -preset $QUAL -r $FPS -g $(($FPS * 2)) -b:v $VBR \
            -acodec libmp3lame -ar 44100 -b:a 712000 -bufsize 512k \
            -f flv -flvflags no_duration_filesize "$YOUTUBE_URL/$KEY"

            PLAYCURSOR=$((PLAYCURSOR+ (duration_seconds-skip_seconds)))
            skip_seconds=0
            KEEP_SKIPPING=0
            echo "Playback complete. PLAYCURSOR AT `$DATE_CMD -d @$PLAYCURSOR`"
            echo "=++++++========+++++======++++++========+++++======++++++========+++++======++++++========+++++=====" 
            continue
        fi
    fi

    if [ "$KEEP_SKIPPING" == "1" ]; then 
        if [ $CURRENT_TIME -lt $((PLAYCURSOR+duration_seconds)) ]; then 
            #echo "current time < end time"
            skip_seconds=$(( duration_seconds - ((PLAYCURSOR+duration_seconds) - CURRENT_TIME)))
            skip_seconds=$((skip_seconds<0 ? 0 : skip_seconds))
            SKIP_NEXT=0
            echo "Marking item for playback after $skip_seconds seconds. PLAYCURSOR AT `$DATE_CMD -d @$PLAYCURSOR`"
            continue
        else 
            #echo "current time > end time"
            PLAYCURSOR=$((PLAYCURSOR+duration_seconds))
            SKIP_NEXT=1
            echo "Marking item for skip. PLAYCURSOR NOW AT `$DATE_CMD -d @$PLAYCURSOR`"
            continue
        fi    
    fi

done < $M3U

echo "Playlist finished"
