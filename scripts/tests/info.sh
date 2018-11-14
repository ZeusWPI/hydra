#!/usr/bin/env bash

set -euo pipefail

# Validate info-related items.
# This script takes the location of the info source files (often in /server/info) as argument.
# It is assumed that the info-content schema is in the same directory as this script.

if [[ $# -lt 1 ]]; then
    echo "Missing parameters." >&2
    echo "Use: $0 folder" >&2
    exit 2
fi

if [[ ! -d "$1" ]]; then
    echo "The input directory '$1' is not a valid path." >&2
    exit 2
fi

schema="info-content.json"

if [[ ! -f ${schema} ]]; then
    echo "The JSON schema file could not be found." >&2
    exit 1
fi

# Execute checks.
./validators/json.sh "$1/nl/info-content.json" ${schema} &&
./validators/json.sh "$1/en/info-content.json" ${schema} &&
./validators/html.sh "$1"

# Return the status code of the validator.
exit $?