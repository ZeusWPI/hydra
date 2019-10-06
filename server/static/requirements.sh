#!/usr/bin/env bash
#
# Install and check for packages needed for "compiling" the static data.
#
# Arguments:
#   None.

set -euo pipefail

# Check that every string in a given array is callable as a command.
#
# Arguments:
#   A series of commands to check.
function check() {
    for i in "$@"; do
        command -v "$i" &>/dev/null || { echo >&2 "error: $i is not installed"; exit 1; }
    done
}

# System libraries
check "mogrify"

echo "All dependencies are installed."
