#!/bin/bash

#
# USAGE: From inside the parent's parent directory run
#
# ./os/linux/build-clamav.sh <FRESCHCLAM_CONFIG_DIR> <DATABASE_DIR>
#

FRESCHCLAM_CONFIG_DIR=$1
DATABASE_DIR=$2

cd clamav-latest
./configure --enable-check
sudo make uninstall
make -j2                                                # Compile ClamAV
make check                                              # Run unit tests
sudo cp freshclam.conf $FRESCHCLAM_CONFIG_DIR           # freshclam configuration
sudo make install                                       # Install ClamAV
sudo mkdir -p /usr/local/share/clamav
sudo mkdir -p $DATABASE_DIR                             # Database dir creation
sudo ldconfig                                           # Download signature databas

exit 0
