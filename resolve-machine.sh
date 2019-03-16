#!/bin/bash

#
# Running the present script from inside another script makes
# the udnerlying operating system's type available as the
# MACHINE variable.
#
# Currently recognizable types: Linux, Mac
#

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          MACHINE="UNKNOWN: ${unameOut}"
esac

export MACHINE
