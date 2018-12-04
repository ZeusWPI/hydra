#!/usr/bin/env bash
#
# Run the resto scraper.
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

if [[ $# -lt 2 ]]; then
    echo "error: both input and output operands are required" >&2
    usage
    exit 1
fi

# Paths are created in Python, we don't need to check for existence here.
output1=$(realpath -s "$1")
output2=$(realpath -s "$2")

# Update symlink
rm -f "$output1/week"
ln -s "$output1/menu/$(date +%Y)" "$output1/week"

# Get the directory of this script file
# see https://stackoverflow.com/a/246128/1831741
SOURCE="${BASH_SOURCE[0]}"
while [[ -h "$SOURCE" ]]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
dir="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"

# Run scraper
echo "Scraping all the menus"
command="$dir/resto.py $output1 $output2"
eval ${command}

echo "Applying manual changes"
command="$dir/resto_manual.py $output2"
eval ${command}

echo "Eating all the sandwiches"
command="$dir/sandwiches.py $output2"
eval ${command}

echo "Finding all the desserts"
command="$dir/cafetaria.py $output2"
eval ${command}

echo "Resto scraper ran successfully."
