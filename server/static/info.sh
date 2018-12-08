#!/usr/bin/env bash
#
# Create the information pages
#
# Use:
#   info.sh input output
# Arguments:
#   input   The path to the folder with the source data (server/static/info/)
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

echo "Copying static data..."

# We copy the whole folder into the public folder. (we cannot symlink, see later).
# Note that all *.html files in the root are present for backwards compatibility only.
rsync -a "$input/" "$output/"

# As the Dutch content used to be available in the root, we must also copy that to that root.
rsync -a "${input}/nl/" "$output/"

echo "Providing compatibility..."
# Ugly replace to fix CSS in the compatibility file.
sed -i 's;<link href="../webview.css" rel="stylesheet" type="text/css"/>;<link href="webview.css" rel="stylesheet" type="text/css"/>;' "${output}/info-fietsen.html"

echo "Info copied successfully."
