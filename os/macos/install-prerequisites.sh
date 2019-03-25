#!/bin/bash

#
# USAGE:
#
#
#

# Install libraries
echo "installing brew dependencies"

if type xcode-select >&- && xpath=$( xcode-select --print-path ) &&
    test -d "${xpath}" && test -x "${xpath}" ; then
    echo "xcode is installed"
else
  xcode-select --install
fi

brew ls --versions pcre2 openssl json-c >/dev/null || brew install openssl json-c

# Install unit testing dependencies
echo
brew ls --versions valgrind check >/dev/null || brew install valgrind check

echo "brew libraries are installed"
exit 0
