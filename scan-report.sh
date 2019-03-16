#!/bin/bash

# USAGE
#./scan-report.sh <DIR_TO_SCAN> <EMAIL_TO>
#

echo

DIR_TO_SCAN=$1;
DIR_SIZE=$(sudo du -sh "$DIR_TO_SCAN" 2>/dev/null | cut -f1);       # humam readable size
DIR_SIZE_KBYTES=$(sudo du -s "$DIR_TO_SCAN" 2>/dev/null | cut -f1); # size in kilobytes
EMAIL_TO=$2
EMAIL_BODY="Please read the .log file attached"
SUBJECT="* ClamAV: MALWARE FOUND *"

# Update ClamAV database

echo
echo "Updating ClamAV database..."
sleep .75
echo
sudo freshclam --verbose
sleep .75
echo
echo "ClamAV database updated"
sleep .75

# Resolve niceness: be rude to others (bigger size -> higher priority)

N=0                                                    # system default value

if [ "$DIR_SIZE_KBYTES" -ge $((5*$((10**8)))) ]; then  # 500 GB <= size
  N=-10
elif [ "$DIR_SIZE_KBYTES" -ge $((10**8)) ]; then       # 100 GB <= size < 500 GB
  N=-8
elif [ "$DIR_SIZE_KBYTES" -ge $((10**7)) ]; then       #  10 GB <= size < 100 GB
  N=-6
elif [ "$DIR_SIZE_KBYTES" -ge $((10**6)) ]; then       #   1 GB <= size < 10 GB
  N=-4
elif [ "$DIR_SIZE_KBYTES" -ge $((10**5)) ]; then       # 100 MB <= size < 1 GB
  N=-2
fi

# Print info about scanning to follow

echo
echo "Directory to be scanned    : $DIR_TO_SCAN"
sleep .75
echo "Approximate amount of data : $DIR_SIZE"
sleep .75
echo "Niceness level             : $N"
sleep .75

# Create log-file and directory of detected files

LOG_FILE="clamav_$(sudo date +"%Y-%m-%d_%H-%M-%S").log"      # Identified by date-time
touch $LOG_FILE
# sudo rm -rf ~/INFECTED/* && mkdir -p ~/INFECTED

# Perform scanning

echo "Started at                 : $(sudo date +"%H:%M:%S, %Y-%m-%d")"
echo
echo "Scanning..."
echo
# sudo nice -n"$N" clamscan -ri --move=~/INFECTED --exclude-dir=~/INFECTED/ $DIR_TO_SCAN &> $LOG_FILE
sudo nice -n"$N" clamscan -ri $DIR_TO_SCAN &> $LOG_FILE

# Create and send report mail, if infected files have been detected

MALWARE=$(tail "$LOG_FILE" | grep Infected | cut -d" " -f3); # Number of infected files

if [ "$MALWARE" -ne "0" ]; then                              # Infected files have been detected

  echo "Infected files detected. Sending report..."
  # tar -czf ~/INFECTED.tar.gz ~/INFECTED

  sudo cp "$LOG_FILE" "~/clamAV-logs/$LOG_FILE"
  echo $EMAIL_BODY | sudo mutt -s $SUBJECT $EMAIL_TO -a $LOG_FILE #INFECTED.tar.gz

  echo
  echo "Report has been sent"

  #rm INFECTED.tar.gz

else                                                         # No infected files have been detected

  echo "No infected files have been detected."

fi

# Delete log-file and directory of detected files, then exit

sudo rm -rF "$LOG_FILE"
echo
echo "Script finished."
exit 0
