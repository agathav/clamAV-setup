#!/bin/bash

#
# USAGE: Run the script without arguments from inside any directory
# prepending its reslative path
#

sudo sed -i '/clamav/d' /etc/group                      # Delete group if it already exists
sudo groupadd clamav                                    # Create the clamav group
sudo useradd -g clamav -s /bin/false -c "clamAv" clamav # Create the clamav user account
sudo chown -R clamav:clamav /usr/local/share/clamav     # Set user ownership for the database directory

exit 0
