#!/usr/bin/env bash
#
# Run tests on Travis.
#
# Use:
#   resto.sh input output
# Arguments:
#   input   The path to the folder with the source data (server/static/association/)
#   output  The root output path. The script will put the final output in that folder.

set -euo pipefail

program=$(basename "$0")

function usage() {
    echo "usage: $program input output"
    echo "where:"
    echo "    output1  path for v1.0 of the API"
    echo "    output   path for v2.0 of the API"
}

check_install="tests/test.sh"
"$check_install"

run_test="tests/test.sh"
"$run_test"
