#!/bin/bash
set -e
# set mode to production when building the project for production, otherwise set to development
MODE="development"
#MODE="production"

STACKSIZE=40m
HEAPSIZE=20m
# add clm to PATH: done in docker container in /etc/bash.bashrc 
script_dir=$(dirname $0)

# projects: list of modules with Start function which each should be builded
# note: the builded executable gets the same name as the module
projects=( "bibber" )
# libs=(StdEnv ArgEnv) # StdEnv is by default already included by clm
libs=( StdEnv ArgEnv )
srcDirs=( "src" "src/WrapDebug" )



# customize clm build with options (used in below variables)
# ----------------------------------------------------------
#
# from src: run 'clm --help' to display help options
#  -nr           Disable displaying the result of the application
#  -t -nt        Enable/disable displaying the execution times
#  -b -sc        Display the basic values or the constructors (default: -sc)
#  -lt -nlt      Enable/disable listing only the inferred types (default: -nlt)
#               (note: strictness information is never included)
#  -lat -nlat    Enable/disable listing all the types (default: -nlat)

#configure options below by choosing one of the two lines per option
#showResult=""           # show result of application (default)
showResult="-nr"         # do not show result of application
#showTime="-t"           # Enable displaying the execution times (default)
showTime="-nt"           # Enable/disable displaying the execution times
#showConstructors="-b"   # Show only basic values without constructors.
showConstructors="-sc"   # Show values with constructors. (default)
#listDeferredType="-lt"  # Enable listing only the inferred types
listDeferredType="-nlt"  # Disable listing only the inferred types (default)
listTypes="-lat"         # enable listing of all types
#listTypes="-nlat"       # disable listing of all types (default)
if [[ "$MODE" == "development" ]]; then
  # development mode
  printStackTraceOnError="-tst"  # enabled; generate code for stack tracing which makes clean to print the callstack when the error happens.
else
  # production mode
  printStackTraceOnError=""       # disable; no code generated for stack tracing (default)
fi


build_script() {
  local prj_dir prj_name line
  prj_dir="$1"
  prj_name="$2"
  line="------------------------------------------------------------------"
  
  libargs=()
  for lib in "${libs[@]}"
  do
    libargs+=( "-IL" "$lib" )
  done 
  
  srcargs=()
  for srcDir in "${srcDirs[@]}"
  do
    srcargs+=( "-I" "$prj_dir/$srcDir" )
  done 


  # clm command run; configure the options with variables above
  cmd=( clm   $showResult $showTime $showConstructors $listDeferredType $listTypes $printStackTraceOnError -ci  -h $HEAPSIZE -s $STACKSIZE "${srcargs[@]}" "${libargs[@]}"  "$prj_name" -o "$prj_dir/bin/$prj_name" )

  ## Background info why -ci option should always be enabled
  ##   If with checking array indices enabled (clm option -ci) and you get error 'Run Time Error: index out of range',
  ##   then enable Stack Tracing profile (clm option -tst) to  'Generate code for stack tracing'.
  ##   This makes clean to print the callstack when the error happens, so that you can locate
  ##   where the error occurs in the code. 
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
for prj_name in  "${projects[@]}"; do
  build_script "$script_dir" "$prj_name" 
done
