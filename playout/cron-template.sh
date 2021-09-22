#!/usr/bin/env bash 

# Contributors: http://github.com/raviu/, https://github.com/mettavihari
# Last Updated: 22-09-2021
# Version: v0.0.4

CHANNEL_IDENTIFIER=channel_1
IPTV_LIVE_PIDS_LOCATION=/opt/dls-2/iptv-live-$CHANNEL_IDENTIFIER.pids

## Kill currently running iptv-live.sh processes based on pids file stored in IPTV_LIVE_PIDS_LOCATION
while read -r pid; do
  echo "Killing previous process $pid"
  kill -9 $pid
done < $IPTV_LIVE_PIDS_LOCATION

rm $IPTV_LIVE_PIDS_LOCATION

## Kill ffmpeg processes that may still be running 
mapfile -t FFMPEG_CHANNEL_PIDS < <( pgrep -d " " -f ^ffmpeg.*$CHANNEL_IDENTIFIER.* )
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

/opt/dls-2/iptv-live.sh --m3u /home/edu/playlists/$CHANNEL_IDENTIFIER\_360/${MONTH,,}-$DAY.m3u --url 127.0.0.1:3011 & 
PIDS+=($!)

/opt/dls-2/iptv-live.sh --m3u /home/edu/playlists/$CHANNEL_IDENTIFIER\_480/${MONTH,,}-$DAY.m3u --url 127.0.0.1:3011 &
PIDS+=($!)

/opt/dls-2/iptv-live.sh --m3u /home/edu/playlists/$CHANNEL_IDENTIFIER\_720/${MONTH,,}-$DAY.m3u --url 127.0.0.1:3011 & 
PIDS+=($!)

for pid in "${PIDS[@]}"
do
    echo "$pid" >> $IPTV_LIVE_PIDS_LOCATION
done
