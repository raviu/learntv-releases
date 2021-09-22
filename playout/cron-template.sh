#!/usr/bin/env bash 

# Contributors: http://github.com/raviu/, https://github.com/mettavihari
# Last Updated: 22-09-2021
# Version: v0.0.5

CHANNEL_IDENTIFIER=channel_1
PORT_360=3011
PORT_480=3012
PORT_720=3013

IPTV_LIVE_PIDS_LOCATION=/opt/dls-2/iptv-live-$CHANNEL_IDENTIFIER.pids

## Kill currently running iptv-live.sh processes based on pids file stored in IPTV_LIVE_PIDS_LOCATION
while read -r pid; do
  echo "Killing previous process $pid"
  kill -9 $pid
done < $IPTV_LIVE_PIDS_LOCATION

rm $IPTV_LIVE_PIDS_LOCATION

## Kill ffmpeg processes that may still be running 
mapfile -t FFMPEG_PORT_360 < <( pgrep -d " " -f ^ffmpeg.*$CHANNEL_IDENTIFIER.*$PORT_360.* )
mapfile -t FFMPEG_PORT_480 < <( pgrep -d " " -f ^ffmpeg.*$CHANNEL_IDENTIFIER.*$PORT_480.* )
mapfile -t FFMPEG_PORT_720 < <( pgrep -d " " -f ^ffmpeg.*$CHANNEL_IDENTIFIER.*$PORT_720.* )

FFMPEG_CHANNEL_PIDS=("${FFMPEG_PORT_360[@]}" "${FFMPEG_PORT_480[@]}" "${FFMPEG_PORT_720[@]}") 
for ffmpeg_pid in "${FFMPEG_CHANNEL_PIDS[@]}"
do
    echo "Killing ffmpeg process $ffmpeg_pid"
    kill -9 $ffmpeg_pid
done

DATE_CMD="date"
if [[ $OSTYPE == 'darwin'* ]]; then
  DATE_CMD="gdate"
fi

MONTH=`$DATE_CMD +%b`
DAY=`$DATE_CMD +'%-d'`

PIDS=()

/opt/dls-2/iptv-live.sh --m3u /home/edu/playlists/$CHANNEL_IDENTIFIER\_360/${MONTH,,}-$DAY.m3u --url 127.0.0.1:$PORT_360 & 
PIDS+=($!)

/opt/dls-2/iptv-live.sh --m3u /home/edu/playlists/$CHANNEL_IDENTIFIER\_480/${MONTH,,}-$DAY.m3u --url 127.0.0.1:$PORT_480 &
PIDS+=($!)

/opt/dls-2/iptv-live.sh --m3u /home/edu/playlists/$CHANNEL_IDENTIFIER\_720/${MONTH,,}-$DAY.m3u --url 127.0.0.1:$PORT_720 & 
PIDS+=($!)

for pid in "${PIDS[@]}"
do
    echo "$pid" >> $IPTV_LIVE_PIDS_LOCATION
done
