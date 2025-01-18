#!/bin/bash
set -e

# add clm to PATH: done in docker container in /etc/bash.bashrc 
script_dir=$(dirname $0)

# install clean 3.1 in clean/ subdir
wget https://ftp.cs.ru.nl/Clean/Clean31/linux/clean3.1_64.tar.gz 
tar xzvf clean3.1_64.tar.gz && rm clean3.1_64.tar.gz
make -C clean
echo 'export PATH="$PATH:'$script_dir'/clean/bin/:'$script_dir'/clean/exe/"' >> /etc/bash.bashrc




