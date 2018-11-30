#!/usr/bin/env bash
#
# Install and check for packages needed for running the tests.
#
# Arguments:
#   None.
# Exit codes:
#   0       All dependencies are present or could be installed.
#   other   An error occurred.

set -euo pipefail

# Check that every string in a given array is callable as a command.
#
# Arguments:
#   A series of commands to check.
function check() {
    for i in "$@"; do
        if ! command -v "$i" &> /dev/null; then
            echo "$0 requires $i to be installed." >&2
            exit 2
        fi
    done
}

# System libraries
check 'java', 'python', 'npm'

# Install packages
pip install html5validator
npm install -g ajv-cli

# Validate packages are installed correctly.
check 'html5validator', 'ajv'
