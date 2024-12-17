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

  cmd=( clm -nr -nt -h $HEAPSIZE -s $STACKSIZE "${libdirargs[@]}" "${libargs[@]}"  "$prj_name" -o "$prj_dir/bin/$prj_name" ) 

  mkdir -p "$prj_dir/bin/"
  printf "\n$line\n    $prj_name\n$line\n - project name: $prj_name\n - project dir: $prj_dir\n - command to be builded : $prj_dir/bin/$prj_name\n\n"
  echo "running:" "${cmd[@]}"
  "${cmd[@]}"
   printf "\nThe builded command can be found in : $prj_dir/bin/$prj_name\n\n"
}

# cleanup old build(s) 
echo bash $script_dir/clean.bash
bash $script_dir/clean.bash
# build project(s)
for prj_name in  "${projects[@]}"; do
  build_script "$script_dir" "$prj_name" 
done
