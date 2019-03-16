#!/bin/bash

#
# USAGE:
#
#
#

# Install libraries
echo
xcode-select --install
brew install pcre2 openssl json-c

# Install unit testing dependencies
echo
brew install valgrind check

exit 0
