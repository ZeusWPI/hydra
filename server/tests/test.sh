#!/usr/bin/env bash
#
# Run the tests for the Hydra API
#
# Use:
#   test.sh server
# Arguments:
#   server  The path to the server directory.
# EXIT CODES:
#   0       Test were run successfully.
#   other   The test failed or an unknown error occurred.

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

server="$1"
if [[ ! -d "$server" ]]; then
    echo "error: $server is not a valid directory" >&2
    usage
    exit 1
else
    # Remove trailing slashes
    server=$(realpath -s "$server")
fi

###############################################################################
# HTML files
###############################################################################

echo "Validating website..."
html5validator --root "$server/static/website" --show-warnings --also-check-css --also-check-svg

echo "Validating information web pages..."
html5validator --root "$server/static/info" --show-warnings --also-check-css --also-check-svg

###############################################################################
# JSON files
###############################################################################

echo "Validating info..."
info="server/static/info"
ajv test -s "server/tests/schema_info-content.json" -d "$info/nl/schema_info-content.json"
ajv test -s "server/tests/schema_info-content.json" -d "$info/en/schema_info-content.json"

echo "Validating special events..."
ajv test -s "server/tests/schema_special_events.json" -d "server/static/association/special_events.json"

echo "Tests completed successfully."