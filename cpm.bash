#!/bin/bash

script_dir=$(dirname $0)

if [[ -d "$script_dir/clean" ]]; then
    source "$script_dir/env.bash"
fi

echo "Using Clean in $CLEAN_HOME"
cpm "$@"
echo "Using Clean in $CLEAN_HOME"
