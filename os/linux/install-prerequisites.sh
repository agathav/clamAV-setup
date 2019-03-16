#!/bin/bash

#
# USAGE: Run the script without arguments from inside any directory
# prepending its reslative path
#

echo
sudo apt-get update

# Install Libraries
echo
packages=(gcc
          clang
          build-essential
          openssl
          libssl-dev
          libcurl4-openssl-dev
          zlib1g-dev
          libpng-dev
          libxml2-dev
          libjson-c-dev
          libbz2-dev
          libpcre3-dev
          ncurses-dev)

already_installed=()

for package in "${packages[@]}"
do
  dpkg -s $package >/dev/null 2>&1 && {
      echo " * $package already installed"
  } || {
      sudo apt-get install -y $package
      already_installed+=( $package )
  }
done

# Install unit testing dependencies
echo
sudo apt-get install valgrind check

exit 0
