#!/usr/bin/env bash

# First argument is input, second is output.
set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Missing parameters." >&2
    echo "Use: $0 source output" >&2
    exit 2
fi

if [[ ! -d "$1" ]]; then
    echo "The input directory '$1' is not a valid path." >&2
    exit 2
fi

if ! command -v npm &> /dev/null ; then
    echo "$0 requires npm to be installed." >&2
    exit 4
fi

if [[ -d "$2" ]]; then
    rm -r "$2"
fi

# Make sure we are in the correct directory.
cd "$1"

echo "Installing Google Assistant"
echo -n "Setting up files..."

# Use absolute paths
input=$(realpath "$1")
output=$(realpath "$2")

# We don't copy the files, but symlink to this directory.
ln -snf "$input" "$output"

echo " OK"
echo "Installing server..."
npm install