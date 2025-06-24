#!/bin/bash
set -e
# set mode to production when building the project for production, otherwise set to development
MODE="development"
#MODE="production"

# projects: list of modules with Start function which each should be builded
# note: the builded executable gets the same name as the module
projects=("bibber")
# We specify the most common libs to be included for convenience.
# Note:
#  - StdEnv is by default already included by clm
#  - Platform contains a moderner directory library, so we do not include Directory
libs=(ArgEnv StdLib Platform TCPIP Gast)
srcDirs=("src" "src/WrapDebug")

STACKSIZE=40m
HEAPSIZE=20m

#configure show options below by choosing one of the two lines per option (uncomment one of the two lines)
#-------------------------------------------------------------------------
showResult="" # Show result of application. (return value of Start function) (default)
#showResult="-nr"         # Do not show result of application.
#showTime="-t"           # Enable displaying the execution times (default)
showTime="-nt" # Disable displaying the execution times
#showConstructors="-b"   # Show only basic values without constructors.
showConstructors="-sc" # Show values with constructors. (default)
# for more info see: run 'clm --help' to display help options

# change compiler
#--------------------------------------------------
# note: after changing the compiler, you need to run 'bash cleanup.bash' to remove the old build first

#clean_compiler="-clc cocl_itask"  # itasks compilers

clean_compiler="-clc cocl" # standard compiler (default)

# below this line we should not change anything
#-------------------------------------------------

# add clm to PATH: done in docker container in /etc/bash.bashrc
script_dir=$(dirname $0)
if [[ -d "$script_dir/clean" ]]; then
    source "$script_dir/env.bash"
fi
echo "Using Clean in $CLEAN_HOME"

# some options we want to enable in development mode but disabled in production mode
if [[ "$MODE" == "development" ]]; then
    # development mode
    printStackTraceOnError="-tst" # enabled; generate code for stack tracing which makes clean to print the callstack when the error happens.
    listTypes="-lat"              # enable listing of all types.  Note: to stderr
else
    # production mode
    printStackTraceOnError="" # disable; no code generated for stack tracing (default)
    listTypes="-nlat"         # disable listing of all types (default)
fi

# from src: run 'clm --help' to display help options
#  -lt -nlt      Enable/disable listing only the inferred types (default: -nlt)   note: to stderr
#               (note: strictness information is never included)
#  -lat -nlat    Enable/disable listing all the types (default: -nlat)            note: to stderr

build_script() {
    local prj_dir prj_name line
    prj_dir="$1"
    prj_name="$2"
    line="------------------------------------------------------------------"

    libargs=()
    for lib in "${libs[@]}"; do
        libargs+=("-IL" "$lib")
    done

    srcargs=()
    for srcDir in "${srcDirs[@]}"; do
        srcargs+=("-I" "$prj_dir/$srcDir")
    done

    # clm command run; configure the options with variables above
    cmd=(clm $clean_compiler $showResult $showTime $showConstructors $listDeferredType $listTypes $printStackTraceOnError -ci -h $HEAPSIZE -s $STACKSIZE "${srcargs[@]}" "${libargs[@]}" "$prj_name" -o "$prj_dir/bin/$prj_name")

    ## Background info why -ci option should always be enabled
    ##   The -ci option enables array indices checking. This is a very useful feature to detect
    ##   out of range errors in the code. It is adviced to always use this option. (even in production!)
    ##   If with checking array indices enabled (clm option -ci) and you get error 'Run Time Error: index out of range',
    ##   then enable Stack Tracing profile (clm option -tst) to  'Generate code for stack tracing'.
    ##   This makes clean to print the callstack when the error happens, so that you can locate
    ##   where the error occurs in the code.
    ##   Note: when -ci option is not enabled, the program will crash probably with segmentation fault
    ##         and you will not get any information about the index out of range error.
    ##   Note: when -tst option is enabled also code in the clean library gets recompiled to enable this feature.
    ##   Note: it is adviced to always use the -ci option. (as is done in nitrile).
    ##   From src: run 'clm --help' to display help options
    ##     -ci -nci      Enable/disable array indices checking
    ##     -tst          Generate code for stack tracing

    mkdir -p "$prj_dir/bin/"
    printf "\n$line\n    $prj_name\n$line\n - project name: $prj_name\n - project dir: $prj_dir\n - command to be builded : $prj_dir/bin/$prj_name\n\n"
    echo "running:" "${cmd[@]}"
    "${cmd[@]}"
    printf "\nThe builded command can be found in : $prj_dir/bin/$prj_name\n\n"
}

# cleanup old build(s)
echo bash $script_dir/cleanup.bash
bash $script_dir/cleanup.bash
# build project(s)
for prj_name in "${projects[@]}"; do
    build_script "$script_dir" "$prj_name"
done
echo "Using Clean in $CLEAN_HOME"
