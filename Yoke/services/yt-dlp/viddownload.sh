#!/usr/bin/env brush
set -e

INPUTFOLDER="."
OUTFOLDER="/mnt/pool1/yt-dlp"
OUTSCHEMA="%(title)s [%(uploader)s] [%(creator)s] [%(webpage_url_domain)s] [p: %(playlist_id)s] [%(id)s].%(ext)s"
SUCCESS=true
DRYRUN=false
NEWLOG=false
FNUM=0
SNUM=0
COOKIES=false
COOKIESOPT=""
COOKIESPATH=""
COOKIEARGS=""

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

while getopts ":i:o:l:c:dh" option "$@"; do
   case $option in
      i) 
         INPUTFOLDER="${OPTARG}";;
      o)
         OUTFOLDER="${OPTARG}";;
      l)
         NEWLOG=true
         LOGFOLDER="${OPTARG}";;
      c) 
         COOKIES=true
         COOKIESOPT="--cookies"
         COOKIESPATH="${OPTARG}";;
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
echo "" > "$FAILFILE"

if [ "$COOKIES" = true ] ; then
    echo "USING COOKIES: $COOKIESPATH"
    echo "USING COOKIES: $COOKIESPATH" >> "$LOGFILE"
fi

cd "$OUTFOLDER"
for i in $(cat "$INPUTFOLDER/input.txt");
do
    echo "DOWNLOADING: $i"
    { 
        if [ "$DRYRUN" = true ] ; then
            echo "DOWNLOADING: $i" >> "$LOGFILE" && sleep 5 && echo "$i" >> "$LOGFILE" 2>&1 && SNUM=$((SNUM+1)) && echo "SUCCESS ($SNUM): $i" &&  echo "SUCCESS ($SNUM): $i" >> "$LOGFILE"
        else
            echo "DOWNLOADING: $i" >> "$LOGFILE" && { 
                if [ "$COOKIES" = true ] ; then
                    yt-dlp -o "$OUTSCHEMA" "$i" $COOKIESOPT "$COOKIESPATH" >> "$LOGFILE" 2>&1
                else
                    yt-dlp -o "$OUTSCHEMA" "$i" >> "$LOGFILE" 2>&1
                fi
                
            } && SNUM=$((SNUM+1)) && echo "SUCCESS ($SNUM): $i" &&  echo "SUCCESS ($SNUM): $i" >> "$LOGFILE"
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
