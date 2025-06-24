#!/bin/bash

script_dir=$(dirname $0)
if [[ -d "$script_dir/clean" ]]; then
    source "$script_dir/env.bash"
fi
echo "Using Clean in $CLEAN_HOME"

TEMPLATE_PROJECT="$script_dir/resources/template.prt" 

# --- Global Variables ---
ENVIRONMENT="StdEnv"              # Default environment
declare -a SOURCE_FOLDERS=("src") # Default source folder
declare -a LIB_FOLDERS=()         # Initialize as empty, will be populated by -l

PROJECT_NAME=""    # To store the project name argument
MAIN_MODULE=""     # To store the main module name, defaults to PROJECTNAME if not specified
EXECUTABLE_NAME="" # To store the executable name, defaults to PROJECTNAME if not specified

# --- Function: Display Usage Information ---
usage() {
    local USAGE_MESSAGE="Usage: createProjectFile [-h] [-e ENVIRONMENT] [-s SOURCE] [-l LIB] [-m MODULE] [-o EXEC_NAME ] PROJECTNAME

Description:
  This script creates a project file based on the specified options.

Arguments:
  PROJECTNAME            The name of the project to be created. This argument is mandatory.

Options:
  -e ENVIRONMENT         Specify the environment for the project.
                         Default: '$ENVIRONMENT'.
                         (On Linux, this is typically found in clean/etc/ folder;
                         on Windows, in the Config folder).

  -s SOURCE              Add an extra source folder to the project file.
                         By default, the 'src' folder is always included.
                         This option can be specified multiple times to add several
                         source folders.

  -l LIB                 Add an extra library folder to the project file.
                         These folders are added in addition to any libraries
                         specified within the chosen environment.
                         This option can be specified multiple times to add several
                         library folders.

  -m MODULE              Specify the name of the main module for the project.
                         This module must be located directly in the 'src' directory
                         (e.g., 'src/MyModule.icl').
                         Default: PROJECTNAME.icl (e.g., if PROJECTNAME is 'MyProject',
                         the default module would be 'MyProject.icl').

  -o EXEC_NAME           Specify the name of the executable build by the project in the 
                         project's bin directory.
                         Default: PROJECTNAME 

  -h, --help             Display this help message and exit.

Note:
  To ensure project folder compatibility across Windows and Linux/macOS,
  both 'lib' and 'Libraries' paths are handled internally where appropriate.
"
    echo "$USAGE_MESSAGE"
    exit 0
}

# --- Parse Command Line Options and Arguments ---

# Check for --help specifically before using getopts
for arg in "$@"; do
    case "$arg" in
    --help)
        usage
        ;;
    -h)
        usage
        ;;
    esac
done

# Parse short options using getopts.
while getopts ":e:s:l:m:o:" opt; do
    case "$opt" in
    e)
        ENVIRONMENT="$OPTARG"
        ;;
    s)
        # # First, remove any trailing slash
        # OPTARG="${OPTARG%/}"
        # # Then, replace all slashes with asterisks
        # OPTARG="${OPTARG//\//*}"
        SOURCE_FOLDERS+=("$OPTARG") # Append additional source folder
        ;;
    l)
        # # First, remove any trailing slash
        # OPTARG="${OPTARG%/}"
        # # Then, replace all slashes with asterisks
        # OPTARG="${OPTARG//\//*}"
        LIB_FOLDERS+=("$OPTARG") # Append additional library folder
        ;;
    m)
        MAIN_MODULE="$OPTARG" # Set the main module name
        ;;
    o)
        EXECUTABLE_NAME="$OPTARG" # Set the executable name
        ;;
    \?) # Handle invalid options
        echo "Error: Invalid option -$OPTARG." >&2
        usage
        ;;
    :) # Handle missing arguments for options
        echo "Error: Option -$OPTARG requires an argument." >&2
        usage
        ;;
    esac
done

# Shift off the options so that remaining arguments can be processed
shift $((OPTIND - 1))

# Check if PROJECTNAME is provided as a positional argument
if [ -z "$1" ]; then
    echo "Error: PROJECTNAME is a mandatory argument." >&2
    usage
else
    PROJECT_NAME="$1"
fi

# Set MAIN_MODULE to PROJECT_NAME if it was not explicitly specified
if [ -z "$MAIN_MODULE" ]; then
    MAIN_MODULE="$PROJECT_NAME"
fi

# Set EXECUTABLE_NAME to PROJECT_NAME if it was not explicitly specified
if [ -z "$EXECUTABLE_NAME" ]; then
    EXECUTABLE_NAME="$PROJECT_NAME"
fi

# Construct the full path to the main module file
MAIN_MODULE_FILE="src/$MAIN_MODULE.icl"

# Check if the main module file exists
if [ ! -f "$MAIN_MODULE_FILE" ]; then
    echo "Error: The specified main module file '$MAIN_MODULE_FILE' does not exist." >&2
    exit 1 # Exit with an error code
fi

# --- Main Script Logic (Example) ---
echo "--- Project File Creation Summary ---"
echo "Project Name:      $PROJECT_NAME"
echo "Environment:       $ENVIRONMENT"
echo "Main Module:       $MAIN_MODULE (File: $MAIN_MODULE_FILE)"
echo "Output executable: $EXECUTABLE_NAME (File: bin/$EXECUTABLE_NAME)"
echo "Source Folders:    ${SOURCE_FOLDERS[@]}" # Use array expansion
echo "Library Folders:   ${LIB_FOLDERS[@]}"    # Use array expansion
echo ""

# Example of how you might iterate through the collected folders
# for src_dir in "${SOURCE_FOLDERS[@]}"; do
#     echo "Processing source directory: $src_dir"
# done

# for lib_dir in "${LIB_FOLDERS[@]}"; do
#     echo "Processing library directory: $lib_dir"
# done

# create project from template and set PROJECT_NAME in it
sed -e "s/{ProjectName}/${PROJECT_NAME}/g" -e "s/{MainModuleName}/${MAIN_MODULE}/g" "$TEMPLATE_PROJECT" >"${PROJECT_NAME}.prj"


# then we set environment with cpm
cpm project "${PROJECT_NAME}.prj" target "${ENVIRONMENT}"

for LIB_FOLDER in "${LIB_FOLDERS[@]}"; do
    # First, remove any trailing slash
    LIB_FOLDER="${LIB_FOLDER%/}"
    # Then, replace all slashes with asterisks
    LIB_FOLDER="${LIB_FOLDER//\//*}"
    cpm project "${PROJECT_NAME}.prj" path add "{Application}*lib*${LIB_FOLDER}"
    cpm project "${PROJECT_NAME}.prj" path add "{Application}*Libraries*${LIB_FOLDER}"
done

for SOURCE_FOLDER in "${SOURCE_FOLDERS[@]}"; do
    # First, remove any trailing slash
    SOURCE_FOLDER="${SOURCE_FOLDER%/}"
    # Then, replace all slashes with asterisks
    SOURCE_FOLDER="${SOURCE_FOLDER//\//*}"
    cpm project "${PROJECT_NAME}.prj" path add "{Project}*${SOURCE_FOLDER}"
done

# finally we fix output path with cpm
cpm project "${PROJECT_NAME}.prj" exec "{Project}*bin*${EXECUTABLE_NAME}"

exit 0
