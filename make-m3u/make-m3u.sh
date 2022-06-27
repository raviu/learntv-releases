#!/usr/bin/env bash 

# Contributors: http://github.com/raviu/
# Last Updated: 27-06-2022

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    "--help")       set -- "$@" "-h" ;;
    "--csv")        set -- "$@" "-c" ;;
    "--month")      set -- "$@" "-m" ;;
    "--videopath")  set -- "$@" "-v" ;;
    *)              set -- "$@" "$arg"
  esac
done

# Display help 
function display_help() {
    cat << EOF
make-m3u v0.0.20 generates m3u playlist given CSV file as input

Usage (items inside [] are optional arguments):

./make-m3u.sh -c|--csv <file> -m|--month <month> [-v|--videopath <media directory path>]

Example

./make-m3u.sh --csv /home/learntv/2021-06-meditation-v2.csv --month JUN

Options:
-----------------------------
-c or --csv         CSV file path
-m or --month       Month (must be one of: jan, feb, mar, apr, jun, jul, aug, sep, oct, nov, dec)
-v or --videopath   Media directory location to search in. Deafults to /media/data/video/
-h or --help        Display help
EOF
}

# Global Variables 
MEDIA_PATH=/media/data/video/
NOT_FOUND_FILE=NOT_FOUND.txt
DUPLICATES_FILE=DUPLICATES_FOUND.txt

# Command flag and argument processing
while getopts  ":c:m:v:h" opt; do
    case $opt in 
        c)
            CSV=$OPTARG 
            ;;
        m)
            MONTH=$OPTARG 
            ;;
        v)
            echo "Media path overridden to $OPTARG"
            MEDIA_PATH=$OPTARG 
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
if [ -z "$CSV" ] || [ -z "$MONTH" ]; then
    echo "The -c and -m arguments are required. Please run ./make-m3u.sh --help for help." >&2
    exit 1
fi

months=(jan feb mar apr may jun jul aug sep oct nov dec)

if [[ ! " ${months[*]} " =~ " ${MONTH,,} " ]]; then
    echo "The -m or --month argument must be one of these: jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec. Please run ./make-m3u.sh --help for help." >&2
    exit 1
fi

# Cleanup  
echo "Cleaning up previous $NOT_FOUND_FILE file"
rm $NOT_FOUND_FILE 2>/dev/null
echo "Cleaning up previous $DUPLICATES_FILE file"
rm $DUPLICATES_FILE 2>/dev/null

# Program
DAY=0
echo "Making m3u files from $CSV"
while IFS=, read -r broadcast_time duration video_file_name; do

    if [[ "$duration" == "#day" ]]; then
        ((DAY++))
        if [ -f "${MONTH,,}-$DAY".m3u ]; then
            continue
        fi
        echo "#EXTM3U" > "${MONTH,,}-$DAY".m3u
        continue
    fi

    readarray -td '' video_files < <(find -L "${MEDIA_PATH}" -type f -name "$video_file_name" -print0)
    if [ ${#video_files[@]} -eq 0 ]; then
        echo "Day $DAY "$video_file_name" cannot be found" >> "$NOT_FOUND_FILE"
        continue
    elif [ ${#video_files[@]} -gt 1 ]; then
        echo "Duplicates found for Day $DAY "$video_file_name": " >> "$DUPLICATES_FILE"
        echo "${video_files[@]}" >> "$DUPLICATES_FILE"
    fi

    video_file="${video_files[0]}"
    duration_seconds=$(echo $duration | awk -F':' '{print $1 * 60 * 60 + $2 * 60 + $3}')

    echo "#EXTINF:$duration_seconds,START_TIME:$broadcast_time" >> "${MONTH,,}-$DAY".m3u
    echo "$video_file" >> "${MONTH,,}-$DAY".m3u

done < $CSV

