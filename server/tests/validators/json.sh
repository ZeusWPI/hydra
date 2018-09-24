#!/usr/bin/env bash

# Validate a JSON file against a JSON Schema file.
# This validator requires the NodeJS package ajv-cli.
# See https://github.com/jessedc/ajv-cli.
#
# This script accepts arguments:
#   1. The location of the json file to check.
#   2. The location of the json file to check.

if ! command -v 'ajv' >/dev/null 2>&1; then
    echo >&2 "Run 'npm install -g ajv-cli' to install the JSON validator."
    exit 1
fi

echo "Checking $1..."
ajv test -s "$2" -d "$1" --valid

# Return the exit code
exit $?