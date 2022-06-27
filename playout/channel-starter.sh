#!/usr/bin/env bash 

# Contributors: http://github.com/raviu/, https://github.com/mettavihari
# Last Updated: 27-06-2022
# Version: v0.0.18

# Global Variables 
BASE_LOCATION="/opt/dls-2"
if [[ $OSTYPE == 'darwin'* ]]; then
  BASE_LOCATION="/Users/ravi/Downloads/learntv-yt-streaming"
fi

mkdir -p "$BASE_LOCATION/logs"
mkdir -p "$BASE_LOCATION/pids"

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    "--help")       set -- "$@" "-h" ;;
    "--name")       set -- "$@" "-n" ;;
    "--kill")       set -- "$@" "-k" ;;
    *)              set -- "$@" "$arg"
  esac
done

# Display help 
function display_help() {
    cat << EOF
channel-starter.sh v0.0.18 starts playout of a channel by reading the configuration in $BASE_LOCATION/<channel_name>-config.

Usage (items inside [] are optional arguments):

./channel-start.sh -n|--name <channel name> [ -k|--kill ]

Example

./channel-starter.sh --n channel_1 

Configuration File 
A configuration file with the following contents must exist: 
File name: <channel name>-config
Contents of File: 
<name1>=port1
<name2>=port2
...

For example a config file "channel_1-config" with below content: 
360=3011
480=3012
720=3013

Will result in loading the following playlists & streaming to following udp URLs: 
/home/edu/playlists/channel_1_360/sep-22.m3u  ==> udp://127.0.0.1:3011
/home/edu/playlists/channel_1_480/sep-22.m3u  ==> udp://127.0.0.1:3012
/home/edu/playlists/channel_1_720/sep-22.m3u  ==> udp://127.0.0.1:3013

Options:
-----------------------------
-n or --name        Channel Name. This name is used to identify the playlist location and which config file to use.
-k or --kill        Kill flag. If this flag is passed, the script will only turn off the channel and will not restart. 
-h or --help        Display help
EOF
}

# Command flag and argument processing
while getopts  ":n:kh" opt; do
    case $opt in 
        n)
            CHANNEL_IDENTIFIER="$OPTARG"
            ;;
        k)
            KILL_ONLY=true
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
if [ -z "$CHANNEL_IDENTIFIER" ]; then
    echo "The -n or --name argument is required. Please run ./channel-starter.sh --help for help." >&2
    exit 1
fi

if [ ! -f $CHANNEL_CONFIG ]; then
    echo "A configuration "
fi

IPTV_LIVE_PIDS_LOCATION="$BASE_LOCATION/pids/iptv-live-$CHANNEL_IDENTIFIER.pids"
CHANNEL_CONFIG="$BASE_LOCATION/$CHANNEL_IDENTIFIER-config"

## Load configuration 

declare -A STREAMS
while IFS== read -r key value; do
    STREAMS[$key]=$value
done < $CHANNEL_CONFIG

if [ ${#STREAMS[@]} -eq 0 ]; then
    echo "Please check the config file in $CHANNEL_CONFIG. No config detected! Script will terminate without action."
    exit 1
fi

## Kill currently running iptv-live.sh processes based on pids file stored in IPTV_LIVE_PIDS_LOCATION
if [ -f "$IPTV_LIVE_PIDS_LOCATION" ]; then 
    while read -r pid; do
        echo "Killing iptv-live process $pid"
        kill -9 $pid
    done < $IPTV_LIVE_PIDS_LOCATION
    rm $IPTV_LIVE_PIDS_LOCATION
fi 

## Kill ffmpeg processes that may still be running 
FFMPEG_CHANNEL_PIDS=()

for KEY in "${!STREAMS[@]}"; do
    PORT=${STREAMS[$KEY]}
    mapfile -t FFMPEG_PIDS < <( pgrep -d " " -f ^ffmpeg.*$PORT.* )
    FFMPEG_CHANNEL_PIDS+=("${FFMPEG_PIDS[@]}")
done

for ffmpeg_pid in "${FFMPEG_CHANNEL_PIDS[@]}"
do
    echo "Killing ffmpeg process $ffmpeg_pid"
    kill -9 $ffmpeg_pid
done

if [ "$KILL_ONLY" == "true" ]; then 
    echo "You passed --kill flag so script will only kill the channel processes and will not start."
    exit 0
fi

DATE_CMD="date"
if [[ $OSTYPE == 'darwin'* ]]; then
  DATE_CMD="gdate"
fi

MONTH=`$DATE_CMD +%b`
DAY=`$DATE_CMD +'%-d'`

TODAY=`$DATE_CMD +'%Y-%m-%d'`
PIDS=()

for KEY in "${!STREAMS[@]}"; do
    PORT=${STREAMS[$KEY]}
    /usr/local/bin/iptv-live.sh --m3u /home/edu/playlists/$CHANNEL_IDENTIFIER\_$KEY/${MONTH,,}-$DAY.m3u --url 127.0.0.1:$PORT >> $BASE_LOCATION/logs/$TODAY-$CHANNEL_IDENTIFIER-$KEY-playout.log & 
    PIDS+=($!)
done 

for pid in "${PIDS[@]}"
do
    echo "$pid" >> $IPTV_LIVE_PIDS_LOCATION
done
