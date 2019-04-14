#!/bin/bash

#
# Running the present script from inside another script makes
# the udnerlying operating system's type available as the
# MACHINE_OS variable.
#
# Currently recognizable types: Linux, Mac
#

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     MACHINE_OS=Linux;;
    Darwin*)    MACHINE_OS=Mac;;
    *)          MACHINE_OS="UNKNOWN: ${unameOut}"
esac

export MACHINE_OS
