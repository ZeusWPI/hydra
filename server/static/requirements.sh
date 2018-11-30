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
check "python"

# Install packages
# Use specific versions here, to enable semi-deterministic tests
pip install "Pillow==5.3.0"

echo "All dependencies are installed."
