#!/usr/bin/env brush
set -e

INPUTFOLDER="."
OUTFOLDER="/mnt/pool1/yt-dlp"
SUCCESS=true
DRYRUN=false
NEWLOG=false
FNUM=0
SNUM=0

usage() {
  cat <<EOF
Usage: $0 [-i input_folder] [-o out_folder] [-l log_folder] [-d]
  -i  input folder (contains input.txt)    (default: .)
  -o  output folder                         (default: /mnt/pool1/yt-dlp)
  -l  log folder (if given, will use <log_folder>/viddownload.log)
  -d  dry run
  -h  show this help message
EOF
  exit 2
}

while getopts ":i:o:l:dh" option "$@"; do
   case $option in
      i) 
         INPUTFOLDER="${OPTARG}";;
      o)
         OUTFOLDER="${OPTARG}";;
      l)
         NEWLOG=true
         LOGFOLDER="${OPTARG}";;
      d)
         DRYRUN=true;;
      h) 
         usage;;
      \?) 
         printf 'Error: Invalid option: -%s\n' "${OPTARG}" >&2
         usage;;
      :) 
         printf 'Error: Option -%s requires an argument.\n' "${OPTARG}" >&2
         usage;;
   esac
done

LOGFILE="$INPUTFOLDER/viddownload.log"

if [ "$NEWLOG" = true ] ; then
    LOGFILE="$LOGFOLDER/viddownload.log"
fi

FAILFILE="$OUTFOLDER/fail.txt"

#echo IN $INPUTFOLDER
#echo OUT $OUTFOLDER
#echo LOG $LOGFILE
#echo FAIL $FAILFILE

echo "" > "$LOGFILE"
cd "$OUTFOLDER"
for i in $(cat "$INPUTFOLDER/input.txt");
do
    echo "DOWNLOADING: $i"
    { 
        if [ "$DRYRUN" = true ] ; then
            echo "DOWNLOADING: $i" >> "$LOGFILE" && sleep 5 && echo "$i" >> "$LOGFILE" 2>&1 && SNUM=$((SNUM+1)) && echo "SUCCESS ($SNUM): $i" &&  echo "SUCCESS ($SNUM): $i" >> "$LOGFILE"
        else
            echo "DOWNLOADING: $i" >> "$LOGFILE" && yt-dlp -o "%(title)s [%(uploader)s] [%(id)s].%(ext)s" "$i" >> "$LOGFILE" 2>&1 && SNUM=$((SNUM+1)) && echo "SUCCESS ($SNUM): $i" &&  echo "SUCCESS ($SNUM): $i" >> "$LOGFILE"
        fi
    } || {
        SUCCESS=false
        FNUM=$((FNUM+1))
        echo "FAIL: $i" && echo "FAIL: $i" >> "$LOGFILE" && echo "$i" >> "$FAILFILE"
    }
done

if [ "$SUCCESS" = true ] ; then
    echo "Done, success ($SNUM)" >> "$LOGFILE"
    echo "Done, success ($SNUM)"
else
    echo "Done, $FNUM FAILS" >> "$LOGFILE"
    echo "Done, $FNUM FAILS"
fi
