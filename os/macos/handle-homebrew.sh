#!/bin/bash

which -s brew

if [[ $? != 0 ]] ; then                                              # Install

    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

else                                                                 # Upgrade

    echo "Homebrew is installed. Upgrading..."
    brew update

fi

exit 0
