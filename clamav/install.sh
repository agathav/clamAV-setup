#!/bin/bash

#
# USAGE: From inside the parent directory run
#
# ./clamav/install.sh
#

echo

FRESCHCLAM_CONFIG_DIR="/usr/local/etc/"
DATABASE_DIR="/var/lib/clamav"

./clamav/download-latest.sh               # Download and extract latest version of ClamAV as clamav-latest
source resolve-machine.sh                 # Resolve operating system as MACHINE


if [ $MACHINE = "Linux" ]; then

	./os/linux/install-prerequisites.sh
  ./os/linux/build-clamav.sh $FRESCHCLAM_CONFIG_DIR $DATABASE_DIR
  ./os/linux/configure-users.sh

  # Reload units for clamav-freshclam.service
  sudo service clamav-freshclam start
  sudo systemctl daemon-reload

elif [ $MACHINE = "Mac" ]; then

	./os/macos/handle-homebrew.sh               # Install or upgrade homebrew
  ./os/macos/install-prerequisites.sh
  ./os/macos/build-clamav.sh

  # Build ----------------------------------------------------------------------

  cd clamav-latest
  ./configure --with-openssl=/usr/local/Cellar/openssl/1.0.2l --with-libjson=yes --enable-check

  make -j2                                                # Compile
  make check                                              # Run unit tests
  sudo cp freshclam.conf "$FRESCHCLAM_CONFIG_DIR"         # freshclam configuration
  make install
  sudo mkdir -p /usr/local/share/clamav

  sudo mkdir -p "$DATABASE_DIR"                           # Database dir creation
  sudo update_dyld_shared_cache                           # Download signature database


  # Users and user-privileges cnfiguration -------------------------------------

  sudo chown -R clamav:wheel /var/log/clamav/
  sudo dscl . -create /Groups/clamav                      # Delete group if it already exists
  sudo dscl . -create /Users/clamav                       # Create the clamav user account
  sudo mkdir -p /usr/local/share/clamav
  sudo chown -R clamav: /usr/local/share/clamav           # Set user ownership for the db dir

else

  echo "OS unknown. Exiting"
  exit 2

fi

# Delete installation folder
find . -type 'd' | grep "clamav-latest" | xargs sudo rm -rf

# Update database (final check) ------------------------------------------------

echo "-------------------------------------------------------------------------"
echo "ClamAV DATABASE UPDATE"
echo
sudo freshclam --verbose # final check

sleep .5
echo "-------------------------------------------------------------------------"
clamscan -V
echo
which clamscan
which freshclam
echo
echo "freshclam configuration at: $FRESCHCLAM_CONFIG_DIR"
echo "-------------------------------------------------------------------------"
sleep .5

exit 0
