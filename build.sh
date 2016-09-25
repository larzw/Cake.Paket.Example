#!/usr/bin/env bash

##########################################################################
# This is the Cake bootstrapper script for Linux and OS X.
# This file was originally downloaded from https://github.com/cake-build/resources
# This version was download from https://github.com/larzw/Cake.Paket.Example
# It was modified to use paket (instead of NuGet) for dependency management.
# Feel free to change this file to fit your needs.
##########################################################################

# Define default arguments.
SCRIPT="build.cake"
PAKET="./.paket"
CAKE="./packages/Cake/Cake.exe"
TARGET="Default"
CONFIGURATION="Release"
VERBOSITY="verbose"
DRYRUN=
SHOW_VERSION=false
SCRIPT_ARGUMENTS=()

# Parse arguments.
for i in "$@"; do
    case $1 in
        -s|--script) SCRIPT="$2"; shift ;;
        -p|--paket) PAKET="$2"; shift ;;
        -e|--cake) CAKE="$2"; shift ;;
        -t|--target) TARGET="$2"; shift ;;
        -c|--configuration) CONFIGURATION="$2"; shift ;;
        -v|--verbosity) VERBOSITY="$2"; shift ;;
        -d|--dryrun) DRYRUN="-dryrun" ;;
        --version) SHOW_VERSION=true ;;
        --) shift; SCRIPT_ARGUMENTS+=("$@"); break ;;
        *) SCRIPT_ARGUMENTS+=("$1") ;;
    esac
    shift
done

# Define directories.
PAKET_DIR=$( cd "$( dirname "$PAKET" )" && pwd )

# Make sure the .paket directory exits.
PAKET_FULL_PATH=$PAKET_DIR/.paket
if [ ! -d "$PAKET_FULL_PATH" ]; then
    echo "Could not find .paket at '$PAKET_FULL_PATH'."
    exit 1
fi

# Set the path to the dependencies.
TOOLS_DIR=$PAKET_DIR/packages
export CAKE_PATHS_TOOLS=$TOOLS_DIR

# If paket.exe does not exits then download it using paket.bootstrapper.exe
PAKET_EXE=$PAKET_FULL_PATH/paket.exe
if [ ! -f "$PAKET_EXE" ]; then

    # If paket.bootstrapper.exe exits then run it.
    PAKET_BOOTSTRAPPER_EXE=$PAKET_FULL_PATH/paket.bootstrapper.exe
    if [ ! -f "$PAKET_BOOTSTRAPPER_EXE" ]; then
        echo "Could not find paket.bootstrapper.exe at '$PAKET_BOOTSTRAPPER_EXE'."
        exit 1
    fi

    # Download paket.exe
    mono "$PAKET_BOOTSTRAPPER_EXE"

    if [ ! -f "$PAKET_EXE" ]; then
        echo "Could not find paket.exe at '$PAKET_EXE'."
        exit 1
    fi
fi

# Restore the dependencies
mono "$PAKET_EXE" restore

# Make sure that Cake has been installed.
CAKE_DIR=$( cd "$( dirname "$CAKE" )" && pwd )
CAKE_EXE="$CAKE_DIR/Cake.exe"
if [ ! -f "$CAKE_EXE" ]; then
    echo "Could not find Cake.exe at '$CAKE_EXE'."
    exit 1
fi

# Start Cake
if $SHOW_VERSION; then
    exec mono "$CAKE_EXE" -version
else
    exec mono "$CAKE_EXE" $SCRIPT -verbosity=$VERBOSITY -configuration=$CONFIGURATION -target=$TARGET $DRYRUN "${SCRIPT_ARGUMENTS[@]}"
fi