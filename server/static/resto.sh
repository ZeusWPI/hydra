#!/usr/bin/env bash
#
# Create the static resto data.
#
# Use:
#   rest.sh input output
# Arguments:
#   input   The path to the folder with the source data (server/static/info/)
#   output1 The root output path for the resto API 1.0. The script will put the final output in that folder.
#   output2 The root output path for the resto API 2.0. The script will put the final output in that folder.

set -euo pipefail

program=$(basename "$0")

function usage() {
    echo "usage: $program input output"
    echo "where:"
    echo "    input    path the directory containing the data in the repo"
    echo "    output1  path to the output folder for the api v1.0"
    echo "    output2  path to the output folder for the api v2.0"
}

if [[ $# -lt 3 ]]; then
    echo "error: both input, output1 and output2 operands are required" >&2
    usage
    exit 1
fi

if [[ ! -d "$1" ]]; then
    echo "error: '$1' is not a valid input directory" >&2
    usage
    exit 2
fi

if [[ ! -d "$2" ]]; then
    echo "Creating output directory for v1.0..."
    mkdir -p "$2"
fi

if [[ ! -d "$3" ]]; then
    echo "Creating output directory for v2.0..."
    mkdir -p "$3"
fi

# Remove trailing slashes
input=$(realpath -s "$1")
output1=$(realpath -s "$2")
output2=$(realpath -s "$3")

echo "Copying static resto data..."

rsync -a "${input}/meta_1.0.json" "$output1/meta.json"
rsync -a "${input}/meta_2.0.json" "$output2/meta.json"

echo "Static data copied."
