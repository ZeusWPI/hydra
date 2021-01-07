#!/usr/bin/env bash
#
# Create the association-related data.
#
# Use:
#   info.sh input output
# Arguments:
#   input   The path to the folder with the source data (server/static/association/)
#   output  The root output path. The script will put the final output in that folder.

set -euo pipefail

program=$(basename "$0")

function usage() {
    echo "usage: $program input output"
    echo "where:"
    echo "    input    path the directory containing the data in the repo"
    echo "    output   path to the output folder for the api"
}

if [[ $# -lt 2 ]]; then
    echo "error: both input and output operands are required" >&2
    usage
    exit 1
fi

if [[ ! -d "$1" ]]; then
    echo "error: '$1' is not a valid input directory" >&2
    usage
    exit 2
fi

if [[ ! -d "$2" ]]; then
    echo "Creating output directory..."
    mkdir -p "$2"
fi

# Remove trailing slashes
input=$(realpath -s "$1")
output=$(realpath -s "$2")

echo "Copying special events..."
cp "$input/special_events.json" "$output/special_events.json"

echo "Association-related successfully created."
