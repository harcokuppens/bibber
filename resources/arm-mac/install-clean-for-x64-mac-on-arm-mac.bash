#!/bin/bash

set -e

script_dir=$(dirname $0)
script_dir=${script_dir:?} # aborts with error if script_dir not set

CLEAN_VERSION="3.1"
PATCHFILE="$script_dir/clean${CLEAN_VERSION}.patch"
CLEAN_URL="https://ftp.cs.ru.nl/Clean/Clean31/macosx/clean3.1.zip"


# set CLEAN_HOME to location in your HOME directory where you want to install Clean
# note: when changing some compiler options in your project it can happen Clean
#       recompiles some files in CLEAN_HOME. That's why Clean always must be a
#       single user installation, and not system wide installation, because user 
#       requires write access in CLEAN_HOME. 
export CLEAN_HOME="$HOME/clean${CLEAN_VERSION}"
# get Clean installation in CLEAN_HOME
mkdir -p /tmp/installclean
wget -O /tmp/installclean/clean${CLEAN_VERSION}.zip  "$CLEAN_URL" 
unzip -d "/tmp/installclean" /tmp/installclean/clean${CLEAN_VERSION}.zip     
mv /tmp/installclean/clean "$CLEAN_HOME"
# patch clean3.1 installation for x64 MacOS to build it on ARM MacOS with Xcode
# notes: 
#   - ARM MacOS  can run x64 binaries using Rosetta emulator for x64 
#   - Xcode on ARM MacOS can build x64 binaries when giving the flag '-arch x86_64' to compiler and linker
#   - on installing Clean still some C files are build, and below patch file adds these flags
#     to the compiler and linker in the Makefile's building C files
#wget -O /tmp/installclean/clean3.1.patch "$PATCHFILE"
patch -d "$CLEAN_HOME" -p1 < "$PATCHFILE"
# build Clean
make -C "$CLEAN_HOME"
# make Clean available in system
echo "export CLEAN_HOME=\"\$HOME/clean${CLEAN_VERSION}\"" >> ~/.bashrc
echo 'export PATH="$PATH:$CLEAN_HOME/bin"' >> ~/.bashrc
source ~/.bashrc