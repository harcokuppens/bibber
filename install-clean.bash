#!/bin/bash

# exit at first unexpected error
set -e

# todo
# - first do what I have, macos arm, linux x64, windows x64

usage() {
    local USAGE_MESSAGE="
NAME
   
    install-clean.bash  -  Install the clean distribution 

SYNOPSIS

    install-clean.bash [-h|--help|help] [-c] [-y] [DIRECTORY]

DESCRIPTION 

    Using this command you can automaticaly (re)install Clean at the given DIRECTORY.
    When the DIRECTORY argument is not given it will install Clean in the project's 
    'clean/' subfolder.

    The installation first checks whether an existing Clean installation exists
    at the given installation location. If so, it first asks for permission to
    remove the old installation. With the option '-y' the script takes automatically
    'yes' as answer. 

    With the option '-c' the script automatically adds \$CLEAN_HOME and \$PATH configuration 
    for the Clean installation in '~/.bashrc'.

    With the option '-h' or '--help' it displays this usage message.
"
    echo "$USAGE_MESSAGE"
    exit 0
}

# Functie om commando's uit te voeren voor macOS
run_macos_commands() {
    echo "--- Commands for macOS ($1) ---"
    if [ "$1" == "x86_64" ]; then
        echo "macOS x64."
        # download and unzip clean
        TMP_FILE="/tmp/clean$RANDOM.zip"
        CLEAN_URL="https://ftp.cs.ru.nl/Clean/Clean31/macosx/clean3.1.zip"
        curl -L -o "$TMP_FILE" "$CLEAN_URL"
        # zip already contains clean/ folder so just unzip in project folder
        unzip -d "$PROJECT_DIR" "$TMP_FILE"
        rm "$TMP_FILE"
        # build Clean
        if make -C "$CLEAN_HOME"; then
            # patch environments in Clean installation
            mkdir -p clean/etc/
            cp resources/IDEEnvs.MacOS clean/etc/IDEEnvs
            echo "Succesfully installed Clean"
        else
            echo "Something went wrong when installing Clean"
            exit 1
        fi
    elif [ "$1" == "arm64" ]; then
        echo "macOS ARM."
        # display whether rosetta is active
        sysctl -n machdep.cpu.brand_string
        printf "Rosetta 2 status: "
        /usr/bin/pgrep oahd >/dev/null && echo "active" || echo "inactive"
        if ! /usr/bin/pgrep oahd >/dev/null; then
            echo "ERROR: cannot install Clean x64 on MacOS ARM because Rosetta is not active"
            exit 1
        fi
        # download and unzip clean
        TMP_FILE="/tmp/clean$RANDOM.zip"
        CLEAN_URL="https://ftp.cs.ru.nl/Clean/Clean31/macosx/clean3.1.zip"
        curl -L -o "$TMP_FILE" "$CLEAN_URL"
        # zip already contains clean/ folder so just unzip in project folder
        unzip -d "$PROJECT_DIR" "$TMP_FILE"
        rm "$TMP_FILE"
        # patch  x64 clean for build on ARM mac
        CLEAN_VERSION="3.1"
        PATCHFILE="$PROJECT_DIR/resources/arm-mac/clean${CLEAN_VERSION}.patch"
        patch -d "$CLEAN_HOME" -p1 <"$PATCHFILE"
        # build Clean
        if make -C "$CLEAN_HOME"; then
            # patch environments in Clean installation
            mkdir -p clean/etc/
            cp resources/IDEEnvs.MacOS clean/etc/IDEEnvs
            echo "Succesfully installed Clean"
        else
            echo "Something went wrong when installing Clean"
            exit 1
        fi
    fi
}

# Functie om commando's uit te voeren voor Linux
run_linux_commands() {
    echo "--- Commands for Linux ($1) ---"
    if [ "$1" == "x86_64" ]; then
        echo "Linux x64."
        #cat /etc/os-release
        # download and unzip clean
        TMP_FILE="/tmp/clean$RANDOM.tgz"
        CLEAN_URL="https://ftp.cs.ru.nl/Clean/Clean31/linux/clean3.1_64.tar.gz"
        curl -L -o "$TMP_FILE" "$CLEAN_URL"
        # tgz already contains clean/ folder so just unzip in project folder
        tar -C "$PROJECT_DIR" -xzvf "$TMP_FILE"
        rm "$TMP_FILE"
        # build Clean
        if make -C "$CLEAN_HOME"; then
            # patch environments in Clean installation
            mkdir -p clean/etc/
            cp resources/IDEEnvs clean/etc/
            echo "Succesfully installed Clean"
        else
            echo "Something went wrong when installing Clean"
            exit 1
        fi
    elif [[ "$1" == "aarch64" || "$1" == "armv7l" || "$1" == "armv6l" ]]; then
        echo "Linux ARM."
        #cat /proc/cpuinfo | grep 'Processor'
        # download and unzip clean
        TMP_FILE="/tmp/clean$RANDOM.tgz"
        CLEAN_URL="https://ftp.cs.ru.nl/Clean/Clean31/linux/clean3.1_64_arm.tar.gz"
        curl -L -o "$TMP_FILE" "$CLEAN_URL"
        # tgz already contains clean/ folder so just unzip in project folder
        tar -C "$PROJECT_DIR" -xzvf "$TMP_FILE"
        rm "$TMP_FILE"
        # build Clean
        if make -C "$CLEAN_HOME"; then
            # patch environments in Clean installation
            mkdir -p clean/etc/
            cp resources/IDEEnvs clean/etc/
            echo "Succesfully installed Clean"
        else
            echo "Something went wrong when installing Clean"
            exit 1
        fi
    fi
}

# Functie om commando's uit te voeren voor Windows (via Git Bash/WSL)
run_windows_commands() {
    echo "--- Commands for Windows ($1) ---"
    if [ "$1" == "x86_64" ]; then
        echo " Windows x64."
        # In Git Bash:
        #cmd //c "systeminfo | findstr /B /C:\"OS Naam\" /C:\"OS Versie\""
        # In WSL (Windows Subsystem for Linux):
        # cat /etc/os-release
    elif [[ "$1" == "aarch64" || "$1" == "arm64" ]]; then # Windows ARM detecteert vaak als aarch64 of arm64
        echo "Windows ARM."
        # via 'cmd //c' or 'powershell.exe -command'."
        # example command via cmd:
        # cmd //c "wmic os get OSArchitecture"
    fi
    # we do x64 install for both windows x64 as ARM, we hope x64 Clean works on ARM windows
    # download and unzip clean
    TMP_FILE="/tmp/clean$RANDOM.zip"
    CLEAN_URL=""https://ftp.cs.ru.nl/Clean/Clean31/windows/Clean_3.1_64.zip""
    curl -L -o "$TMP_FILE" "$CLEAN_URL"
    # zip already contains "Clean 3.1/" folder so just unzip in project folder
    unzip -d "$PROJECT_DIR" "$TMP_FILE"
    mv "$PROJECT_DIR/Clean 3.1/" "$PROJECT_DIR/clean/"
    rm "$TMP_FILE"
    # done Clean already build
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
ALWAYS_YES="false"
ADD_ENV="false"
while getopts ":cy" opt; do
    case "$opt" in
    y)
        ALWAYS_YES="true"
        ;;
    c)
        ADD_ENV="true"
        ;;
    \?) # Handle invalid options
        echo "Error: Invalid option -$OPTARG." >&2
        usage
        ;;
    esac
done

# --- main ---

script_dir=$(dirname $0)
script_dir="$(realpath $script_dir)"
script_dir=${script_dir:?} # aborts with error if script_dir not set
cd "$script_dir" || exit

CLEAN_HOME="$script_dir/clean"
PROJECT_DIR="$script_dir"

# Detecteer het besturingssysteem
OS=$(uname -s)
# Detecteer de architectuur
ARCH=$(uname -m)
echo "Detected OS:$OS and ARCH: $ARCH"

if [[ -d "$CLEAN_HOME" ]]; then
    if [[ "$ALWAYS_YES" == "false" ]]; then
        echo "We detected an existing Clean installation in your project's clean/ subdir."
        echo "We can reinstall Clean, but that will cause that the old install will removed and replace by the new install."
        read -p "Do you want to reinstall (y/N)? " -n 1 -r
        echo # (optional) move to a new line
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Canceled the installation"
            exit 0
        fi
    fi
    # uninstall old version first
    echo "Uninstalling Clean in '$CLEAN_HOME'"
    # remove clean install
    rm -r "$CLEAN_HOME"
    echo "Cleanup any old project builds"
    "$PROJECT_DIR/cleanup.bash"
fi

case "$OS" in
"Darwin") # macOS
    run_macos_commands "$ARCH"
    ;;
"Linux")
    run_linux_commands "$ARCH"
    ;;
"MINGW"* | "CYGWIN"* | "MSYS"*) # Git Bash, Cygwin, MSYS op Windows
    run_windows_commands "$ARCH"
    ;;
*)
    echo "unknown: $OS with architecture: $ARCH"
    exit 1
    ;;
esac

if [[ "$ADD_ENV" == "true" ]]; then
    echo "Add \$CLEAN_HOME and \$PATH configuration for the Clean installation in '~/.bashrc'."
    echo "export CLEAN_HOME=\"$CLEAN_HOME\"" >>~/.bashrc
    echo 'export PATH="$CLEAN_HOME:$CLEAN_HOME/bin:$PATH"' >>~/.bashrc
fi
