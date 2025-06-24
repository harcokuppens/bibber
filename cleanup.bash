#!/bin/bash
set -e

USAGE="
NAME
   
    cleanup.bash  -  Cleanup project and optionally the clean distribution installed in the project.

SYNOPSIS

    cleanup [-h|--help|help] [--all]

DESCRIPTION 

    The project contains:

     - local source files
     - a clean distribution installed in the project folder

    Without options cleanup removes only builds from the local source files in the project.
    With the 'all' option cleanup also removes the clean distribution installed in the project.
    One can always reinstall the clean distribution in your project folder in the container by 
    running in the container the command: ./install-clean-clm.bash

    With the option '-h' or '--help' or argument 'help' it displays this usage message.

"
if [[ "$1" == "-h" || "$1" == "--help" || "$1" == "help" ]]; then
    echo "$USAGE"
    exit 0
fi

echo "Remove builds from the local source files in the project."
script_dir=$(dirname $0)
script_dir=${script_dir:?} # aborts with error if script_dir not set

# cleanup bin/ folder. Make sure an empty bin/ remains, because cpm needs the bin/ folder to exist to write binary in it.
rm -rf "$script_dir/bin"
mkdir "$script_dir/bin"
touch "$script_dir/bin/.gitkeep"
# cleanup builds in src folders in "Clean System Files" folders
find "$script_dir/src" -name 'Clean System Files' -type d -print0 | xargs -0 -I % rm -rf "%"
find "$script_dir/examples" -name 'Clean System Files' -type d -print0 | xargs -0 -I % rm -rf "%"
# also cleanup 'Clean System Files' folder in root folder created when using cpm
rm -rf "$script_dir/Clean System Files"
# note we do not cleanup 'Clean System Files' folders in the clean/ subfolder which would break the Clean installation

if [[ "$1" == "--all" ]]; then
    # also cleanup clean folder
    rm -rf "$script_dir/clean"

    echo ""
    echo "Also remove the clean/ distribution installed in the project's folder."
    echo "To recreate the clean/ folder in your workspace folder in the container run in the container: ./install-clean.bash"
else
    echo "NOTE: to also cleanup the clean installation in the project run: ./cleanup.bash --all"
fi
