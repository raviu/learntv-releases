#!/usr/bin/env bash 

# Contributors: http://github.com/raviu/
# Last Updated: 27-06-2022
# Version: v0.0.17

# Global Variables with defaults                                
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
    "--url")            set -- "$@" "-u" ;;
    "--start")          set -- "$@" "-s" ;;
    *)                  set -- "$@" "$arg"
  esac
done

# Display help 
function display_help() {
    cat << EOF
iptv-live.sh v0.0.17 streams m3u playlist file to IPTV service

Usage (items inside [] are optional arguments):

./iptv-live.sh.sh -m|--m3u <file> -u|--url <streaming url> [ -s|--start <start time in HH:mm:ss> ]

Example

./iptv-live.sh --m3u /home/learntv/dharmavahini/2021/09/sep-4.m3u --url 127.0.0.1:2001

Options:
-----------------------------
-m or --m3u         M3U playlist file path. This argument is required. 
-u or --url         The streaming URL including any ports. Ex: 127.0.0.1:2001
-s or --start       Specify the start time of the playlist in 24 hour format HH:mm:ss. Defaults to 05:00:00 (5AM)
-h or --help        Display help
EOF
}

# Command flag and argument processing
while getopts  ":m:s:u:h" opt; do
    case $opt in 
        m)
            M3U=$OPTARG 
            PLAYLIST_DAY=`basename $OPTARG | cut -d'-' -f2 | cut -d'.' -f1`
            ;;
        s)
            START_TIME=$OPTARG
            ;;
        u)
            URL=$OPTARG
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
if [ -z "$M3U" ] || [ -z "$URL" ]; then
    echo "The -m and -u arguments are both required. Please run ./iptv-live.sh --help for help." >&2
    exit 1
fi 

if [ ! -f "$M3U" ]; then 
    echo "Could not find playlist file $M3U. Terminating."
    exit 1
fi 

PLAYLIST_START_TIME=$($DATE_CMD --date "`$DATE_CMD +'%Y'`-`$DATE_CMD +'%m'`-$PLAYLIST_DAY $START_TIME" "+%s")
echo "PLAYLIST_START_TIME `$DATE_CMD -d @$PLAYLIST_START_TIME`"

TODAY=`$DATE_CMD +'%Y-%m-%d'`
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
            -nostdin -re \
            -i "$line" \
            -ss $skip_seconds \
            -codec copy \
            -f mpegts udp://$URL?pkt_size=1316 >> /var/log/$TODAY-iptv-live-ffmpeg-$URL.log 2>&1

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
