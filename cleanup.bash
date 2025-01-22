#!/bin/bash
set -e

USAGE="
NAME
   
    cleanup.bash  -  Cleanup project and optionally the clean distribution installed in the project.

SYNOPSIS

    cleanup [-h|--help|help] [all]

DESCRIPTION 

    The project contains:

     - local source files
     - a clean distribution installed in the project folder

    Without options cleanup removes only builds from the local source files in the project.
    With the 'all' option cleanup also removes the clean distribution installed in the project.
    One can always reinstall the clean distribution in your project folder in the container by 
     - for clm build run:         ./install-clean-clm 
     - for nitrile build run:     nitrile update; nitrile fetch 

    With the option '-h' or '--help' or argument 'help' it displays this usage message.

"
if [[ "$1" == "-h" || "$1" == "--help" || "$1" == "help" ]]; then
    echo "$USAGE"
    exit 0
fi

echo "Remove builds from the local source files in the project."
script_dir=$(dirname $0)
script_dir=${script_dir:?} # aborts with error if script_dir not set
rm -rf "$script_dir/bin"
# cleanup builds in src folders in "Clean System Files" folders
find "$script_dir/src" -name 'Clean System Files' -type d -print0 | xargs -0 -I % rm -rf "%"

if [[ "$1" == "all" ]]; then
    # also cleanup clean installation in project (clm or nitrile)
    rm -rf "$script_dir/clean"
    rm -rf "$script_dir/nitrile-packages"

    echo ""
    echo "Also remove the clean distribution installed in the project's folder."
    echo "One can always reinstall the clean distribution in your project folder in the container by: "
    echo " - for clm build run:        ./install-clean-clm"
    echo " - for nitrile build run:    nitrile update; nitrile fetch"

else
    echo "NOTE: to also cleanup the clean installation in the project run: ./cleanup.bash all"
fi
