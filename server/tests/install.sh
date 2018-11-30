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
        command -v "$i" &>/dev/null || { echo >&2 "error: $i is not installed"; exit 1; }
    done
}

# System libraries
check "java" "python" "npm"

# Install packages
# Use specific versions here, to enable semi-deterministic tests
pip install "html5validator==0.3.1"
npm install -g "ajv-cli@3.0.0"

# Validate packages are installed correctly.
check "html5validator" "ajv"

echo "All dependencies are installed."
