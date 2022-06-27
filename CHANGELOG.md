
 **2022-06-27**: release.sh add changelog to release repo


 **2022-06-27**: thumbnail-extract.sh: add find command to run script for multiple files into help


 **2022-06-27**: thumbnail-extract.sh: add -qmin 1 so that -q:v 1 actually works


 **2022-06-27**: thumbnail-extract.sh: add image output format flag


 **2022-06-21**: release.sh: add thumnail-extract directory to release


 **2022-06-21**: release.sh: add thumnail-extract directory to release


 **2022-06-21**: thumbnail-extract: add thumbnail-extract to install script and release script


 **2022-06-21**: thumbnail-extract.sh: adding thumbnail extraction script


 **2021-09-23**: channel-starter: playout logs should be per channel identifer + key, not just channel identifier


 **2021-09-23**: channel-starter: make log message clearer


 **2021-09-23**: channel-starter: move pids and logs to directories


 **2021-09-22**: channel-starter: only act on pids file if it exists


 **2021-09-22**: channel-starter: only remove pids file if it exists


 **2021-09-22**: channel-starter: only use port to identify ffmpeg processes


 **2021-09-22**: iptv-live: save ffmpeg output in /var/log/$TODAY-iptv-live-ffmpeg-$URL.log


 **2021-09-22**: release.sh: cron-template is now channel-starter


 **2021-09-22**: install: channel-starter needs to be installed in /usr/local/bin


 **2021-09-22**: install: fix some issues with channel-starter.sh


 **2021-09-22**: iptv-live.sh: add check to terminnate if M3U file is missing!"


 **2021-09-22**: channel-starter: add kill flag functionality and log iptv-live.sh output to log file in BASE_LOCATION


 **2021-09-22**: install: remove cron-template and add channel-starter


 **2021-09-22**: iptv-live: add version in comment


 **2021-09-22**: youtube-live: add version in comments


 **2021-09-22**: channel-starter: new channel starter script to start channels


 **2021-09-22**: cront-template: add configurable ports for cron template


 **2021-09-22**: release: add cront-template.sh to release


 **2021-09-22**: cron: rename to cron-template.sh and new cron-template that kills existing processes bbefore starting playback


 **2021-09-22**: install.sh: add cron_template.sh


 **2021-09-22**: iptv-live: remove new line in first line of script


 **2021-09-22**: release: add version archive to README


 **2021-09-22**: release: detect existing tags and report latest and all tags


 **2021-09-22**: release: test branch name


 **2021-09-22**: release: remove branch on push


 **2021-09-22**: release: use $REPO


 **2021-09-22**: install: add installer script and release automation for release repo


 **2021-09-22**: playout: update scripts with placeholders for version and updated date


 **2021-09-22**: README: add installation and upgrade instructions


 **2021-09-21**: youtube-live.sh: whitespace fix


 **2021-09-21**: youtube-live.sh: YouTube live streaming requires -re for real time streaming. Removed -qscale as it is redundant. Added flvflags no_duration_filesize. Removed threads as ffmpeg can auto detect this value to use


 **2021-09-21**: cron: first line must be shebang


 **2021-09-20**: cron.sh: update contributors


 **2021-09-20**: README: update output descriptions


 **2021-09-20**: playout: update playlist finished output


 **2021-09-20**: playout: add playlist finished output


 **2021-09-20**: make-m3u: validate month input is in supported format


 **2021-09-02**: cron: add sample cron file


 **2021-09-20**: playout: make sure current time updates at start of loop


 **2021-09-20**: READEM: update how to read script output


 **2021-09-20**: README: update how to read output instructions


 **2021-09-20**: README: update how to read script output


 **2021-09-20**: playout: update README with insturctions how to read output


 **2021-09-20**: Fix README


 **2021-09-20**: fix README


 **2021-09-20**: iptv-live.sh: added IPTV playout script. Cleaned up echo output


 **2021-09-07**: Merge pull request #2 from raviu/raviu-patch-1


 **2021-09-07**: Update youtube-live.sh


 **2021-09-07**: Update youtube-live.sh


 **2021-09-07**: Update youtube-live.sh


 **2021-09-07**: Update youtube-live.sh


 **2021-09-06**: Merge pull request #1 from raviu/enable_streaming


 **2021-09-06**: youtube-live: use gnu date and also added -s or start flag to specify the playback start time for the script


 **2021-09-05**: Update youtube-live.sh


 **2021-09-05**: Update README.md


 **2021-09-05**: Merge branch 'main' into enable_streaming


 **2021-09-05**: youtube-live: enable ffmpeg streaming


 **2021-09-06**: README: update usage to show correct m3u filename format


 **2021-09-05**: README: update readme for youtube-live script


 **2021-09-05**: playout/youtube-live: add initial youtube live script with skipping


 **2021-09-05**: make-m3u: add delimiter to EXTINF that is more robust with more entropy


 **2021-09-05**: youtube-live: uncomment echo of ffmpet command


 **2021-09-05**: youtube-live: set playlist start time to 04:59:59 to give cron a chance to start exactly at 05:00:00


 **2021-09-05**: youtube-live.sh: add a guard to not allow streaming before scheduled start time


 **2021-09-05**: make-m3u: add -m/--month argument that is mandatory and make -v video path that is optional with a default


 **2021-09-04**: make-m3u: fix bug where DAY is not incremented when file already exists


 **2021-09-04**: README/tests: update tests to use the media argument and update readme


 **2021-09-04**: make-m3u: pass media directory location as an argument


 **2021-09-04**: .DS_Store banished!


 **2021-09-04**: README: rename old readme so it does not show up as github readme


 **2021-09-04**: README: rename old readme so it does not show up as github readme


 **2021-09-04**: README: add usage output in readme


 **2021-09-04**: README: get rid of link to output folder as it will not exist on git


 **2021-09-04**: tests: run all tests inside output folder for easy cleanup


 **2021-09-04**: tests: delete the make-m3u.sh committed from test run


 **2021-09-04**: gitignore: creaet gitignore file


 **2021-09-04**: README: add instructions on how to test


 **2021-09-04**: README: update readme link


 **2021-09-04**: make-m3u: initial m3u generation scripts


 **2021-09-04**: docs: add requiremetns docs and other resources provided by LearnTV


 **2021-09-04**: README: update README


 **2021-09-04**: Initial commit
