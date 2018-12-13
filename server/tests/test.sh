#!/usr/bin/env bash
#
# Run the tests for the Hydra API
#
# Use:
#   test.sh server
# Arguments:
#   server  The path to the server directory.

set -euo pipefail

program=$(basename "$0")

function usage() {
    echo "usage: $program server"
    echo "where:"
    echo "    server    path the server directory in the repo"
}

if [[ $# -lt 1 ]]; then
    echo "error: missing server operand" >&2
    usage
    exit 1
fi

if [[ ! -d "$1" ]]; then
    echo "error: '$1' is not a valid directory" >&2
    usage
    exit 1
fi

# Remove trailing slashes
server=$(realpath -s "$1")

# Some utils
static="$server/static"
tests="$server/tests"

###############################################################################
# HTML files
###############################################################################

echo "Validating website..."
html5validator --root "$static/website" --show-warnings --also-check-css --also-check-svg

echo "Validating information web pages..."
html5validator --root "$static/info" --show-warnings --also-check-css --also-check-svg

###############################################################################
# JSON files
###############################################################################

echo "Validating info..."
ajv -s "$tests/schema_info-content.json" -d "$static/info/*/info-content.json" --errors=text

echo "Validating special events..."
ajv -s "$tests/schema_special_events.json" -d "$static/association/special_events.json" --errors=text

echo "Tests completed successfully."