#!/bin/bash

#
# USAGE: Run the script without arguments from inside any directory
# prepending its relative path. After running this script, a clamav-latest
# directory will have been created inside the current working directory.
# Enter it to build the latest version of ClamAV.
#

# Download and extract to clamav-latest ----------------------------------------
STATUS="F"

wget -r --no-parent -A 'clamav-*.tar.gz' -q --show-progress -P . https://www.clamav.net/downloads/  &&
mv www.clamav.net/downloads/production/clamav-*.tar.gz ./clamav-latest.tar.gz &&
tar -xzf clamav-latest.tar.gz &&
mkdir -p clamav-latest && tar -xzf clamav-latest.tar.gz -C clamav-latest --strip-components 1 &&
rm -rf clamav-latest.tar.gz www.clamav.net &&

# Delete all clamav-* directories except for clamav-latest ---------------------

find . -type 'd' | grep "clamav-" | grep -v "clamav-latest" | xargs sudo rm -rf && STATUS="S"

# Print info and exit ----------------------------------------------------------
echo
if [ "$STATUS" == "S" ];
then
  echo "Download complete"
  echo "Enter clamav-latest to install the latest version of ClamAV"
  exit 0
else
  echo "The installation failed. Exiting"
  exit 1

fi
