#!/bin/bash

#
# USAGE: From inside the parent directory run
#
# ./clamav/install.sh
#

function unknown_error(){
	echo "-----------------"
	echo "There was an error, exiting"
  exit 2
}

echo

FRESCHCLAM_CONFIG_DIR="/usr/local/etc/"
DATABASE_DIR="/var/lib/clamav"

./download-latest.sh               # Download and extract latest version of ClamAV as clamav-latest
source ../resolve-machine.sh                 # Resolve operating system as MACHINE_OS


if [ $MACHINE_OS = "Linux" ]; then

	../os/linux/install-prerequisites.sh
  ../os/linux/build-clamav.sh $FRESCHCLAM_CONFIG_DIR $DATABASE_DIR
  ../os/linux/configure-users.sh

  # Reload units for clamav-freshclam.service
  sudo service clamav-freshclam start
  sudo systemctl daemon-reload

elif [ $MACHINE_OS = "Mac" ]; then

	../os/macos/handle-homebrew.sh  &&             # Install or upgrade homebrew
  ../os/macos/install-prerequisites.sh &&
  ../os/macos/build-clamav.sh || unknown_error

  # Build ----------------------------------------------------------------------

  cd clamav-latest

  ./configure --with-openssl=/usr/local/Cellar/openssl/$(ls /usr/local/Cellar/openssl/|head -n 1) \
	--with-libjson=yes --enable-check CPPFLAGS="-I/usr/local/opt/openssl@1.0/include" LDFLAGS="-L/usr/local/opt/openssl@1.0/lib/"

  make -j2 >/dev/null  &&                                             # Compile
  make check -s &&                                             # Run unit tests
  sudo cp ../freshclam.conf "$FRESCHCLAM_CONFIG_DIR" &&        # freshclam configuration
  make install -s &&
  sudo mkdir -p /usr/local/share/clamav &&

  sudo mkdir -p "$DATABASE_DIR" || unknown_error                       # Database dir creation
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
cd ../
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
