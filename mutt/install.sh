#!/bin/bash
#
# USAGE: From inside the parent directory run
#
# ./mutt/install.sh <ID> <USERNAME> <PASSWORD> <SERVER>
#

echo

ID=$1
USERNAME=$2
PASSWORD=$3
SERVER=$4

source resolve-machine.sh                # Resolve operating system as MACHINE

# Installation -----------------------------------------------------------------

if [ $MACHINE = "Linux" ]; then                                        # Linux

  sudo apt-get purge --auto-remove mutt -y
  sudo apt-get update
  sudo apt-get install mutt -y

elif [ $MACHINE = "Mac" ]; then                                        # MacOS

  ./macos/handle-homebrew.sh
  brew uninstall -f mutt && brew install mutt

else

  echo "OS unknown. Exiting"
  exit 2

fi

# Configuration ----------------------------------------------------------------

if [ -f ~/.muttrc ]; then

  # Backup pre-existing .muttrc file
  mkdir -p ~/mutt-backup
  sudo mv ~/.muttrc ~/mutt-backup/.muttrc_backup-$(sudo date +"%Y-%m-%d_%H-%M-%S")

fi

# Place configuration file inside user
sudo cp mutt/.muttrc ~/.muttrc
sudo chmod 600 ~/.muttrc                   # User only can only read and write

# Write configuration file
if [ $MACHINE = "Linux" ]; then                                        # Linux

  sudo sed -i "s/ID/$ID/g" ~/.muttrc
  sudo sed -i "s/USERNAME/$USERNAME/g" ~/.muttrc
  sudo sed -i "s/PASSWORD/$PASSWORD/g" ~/.muttrc
  sudo sed -i "s/SERVER/$SERVER/g" ~/.muttrc

else                                                                   # MacOS

  sudo sed -i '' "s/ID/$ID/g" ~/.muttrc
  sudo sed -i '' "s/USERNAME/$USERNAME/g" ~/.muttrc
  sudo sed -i '' "s/PASSWORD/$PASSWORD/g" ~/.muttrc
  sudo sed -i '' "s/SERVER/$SERVER/g" ~/.muttrc

fi

# Print info and exit ----------------------------------------------------------

sleep .5
echo "-------------------------------------------------------------------------"
which mutt
echo
echo "User specific configuration at:"
sudo ls -rtlha ~ | grep -w .muttrc
echo "-------------------------------------------------------------------------"
sleep .5
exit 0
