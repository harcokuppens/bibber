#!/bin/bash
set -e

script_dir=$(dirname $0)
rm -rf "$script_dir/bin"
rm -rf "$script_dir/nitrile-packages"
rm -rf "$script_dir/clean"

#cleanup 'Clean System Files' folders  
find "$script_dir/src"  -name 'Clean System Files' -type d -exec echo {} ';'  | xargs -I % rm -r "%"


echo "For clm build directly: to recreate the clean/ folder in your workspace folder in the container run: ./install-clean-clm "
echo "For nitrile build: to recreate the nitrile-packages/ folder in your workspace folder in the container run: nitrile update; nitrile fetch "


