#!/bin/bash
set -e
STACKSIZE=40m
HEAPSIZE=20m
# add clm to PATH: done in docker container in /etc/bash.bashrc 
script_dir=$(dirname $0)

projects=( "bibber" )
# libs=(StdEnv ArgEnv) # StdEnv is by default already included by clm
libs=( ArgEnv )
libdirs=( "src" "src/WrapDebug" )


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
  
  libdirargs=()
  for libdir in "${libdirs[@]}"
  do
    libdirargs+=( "-I" "$prj_dir/$libdir" )
  done 


  ## Background info: 
  ##   src:  clm --help 
  ##   If with checking array indices enabled (clm option -ci) and you get error 'Run Time Error: index out of range',
  ##   then enable Stack Tracing profile (clm option -tst) to  'Generate code for stack tracing'.
  ##   This makes clean to print the callstack when the error happens, so that you can locate
  ##   where the error occurs in the code. 
  ##   Note: when -tst option is enabled also code in the clean library gets recompiled to enable this feature.
  ##   Note: it is adviced to always use the -ci option. (as is done in nitrile).
  cmd=( clm -lat -ci -nr -nt -h $HEAPSIZE -s $STACKSIZE "${libdirargs[@]}" "${libargs[@]}"  "$prj_name" -o "$prj_dir/bin/$prj_name" ) 
  # used options:
  # from src: run 'clm --help' to display help options
  #  -ci -nci      Enable/disable array indices checking
  #  -nr           Disable displaying the result of the application
  #  -t -nt        Enable/disable displaying the execution times
  # usefull options:
  #  -lt -nlt      Enable/disable listing only the inferred types
  #               (note: strictness information is never included)
  #               (default: -nlt)
  # -lat -nlat    Enable/disable listing all the types
  #               (default: -nlat)
  # -tst          Generate code for stack tracing

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
