script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# for nitrile
export PATH="$script_dir/bin-nitrile:$PATH"


# for classic clean
#
# for MacOS we need to disable nanozone in memory allocation because it has a bug in libmalloc
# src: https://blackwinghq.com/blog/posts/playing-with-libmalloc/
export MallocNanoZone=0

if [[ -d "$script_dir/clean" ]]; then
    export CLEAN_HOME="$script_dir/clean"
    export PATH="$CLEAN_HOME:$CLEAN_HOME/bin:$PATH"
    # note in Windows the cpm command is located in the root of CLEAN_HOME
    echo "Set environment to use Clean in $CLEAN_HOME"
else
    echo "WARNING: environment not changed because local clean/ folder not found"
fi
