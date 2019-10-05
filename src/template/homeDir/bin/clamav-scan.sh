#!/bin/bash
pid="/tmp/clam-scan-$USER.pid"
ctime=$(date +%Y-%m-%d_%H.%M.%S)
log_dir="$HOME/logs/virus"
log_file="$log_dir/scan-$ctime.log"
quarantine_dir="$HOME/quarantine"
DIR=$1
mkdir -p $DIR
mkdir -p $log_dir
mkdir -p $quarantine_dir

echo "Monitoring $1 for malware, virus' etc"

if [ -d "$HOME/quarantine" ]
then
	echo "Infected files will be placed in $HOME/quarantine"

else
	echo "\e[93m\e[1m !! ERROR \e[44m$HOME/quarantine\e[49m not found !!"
fi
touch $pid
touch $log_file
trap "rm -f -- '$pid'" EXIT

IFS=$(echo -en "\n\b")
shopt -s lastpipe
inotifywait --quiet --monitor --event close_write,moved_to --recursive --format '%w%f' $DIR | while read FILE

do
     # Have to check file length is nonzero otherwise commands may be repeated
     if [ -s $FILE ]; then
          # Replace 'date >' with 'date >>' if you want to keep log file entries for previous scans.
	  eval_log_file=$log_dir/.virus-scan.log
          date > $eval_log_file

          SIZE=$(stat -c%s $FILE)
          if [ $SIZE -ge 25000000 ]; then
                notify-send -i /usr/share/icons/gnome/48x48/status/security-low.png "Scanning >25mb..." "$FILE is being scanned."
          fi
          clamdscan --move=$quarantine_dir $FILE >> $eval_log_file
          RESULT=$(egrep -c 'Infected files: [0-9]*[1-9]' $eval_log_file)
#          RESULT=`egrep -c 'Infected files: [0-9]*[1-9]'` $eval_log_file
          echo $eval_log_file >>$log_file

          if [ $RESULT -gt 0 ]; then
                notify-send -i /usr/share/icons/gnome/48x48/status/security-high.png "Infected File" "$(sed -n '/SCAN/{n;p;n;p;n;p}' $eval_log_file) $FILE"
#Uncomment to notify developer of safe file... discouraged as this will result in tiling alerts on screen!
#	      else 
#    			notify-send -i /usr/share/icons/gnome/48x48/status/security-low.png  "Safe File" "$(sed -n '/SCAN/{n;p;n;p;n;p}' $HOME/.virus-scan.log)"
          fi
     fi
done
