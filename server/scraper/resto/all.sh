#!/usr/bin/env bash
#
# Run the resto scraper.
#
# Use:
#   all.sh input output
# Arguments:
#   input   The path to the folder with the source data (server/static/association/)
#   output  The root output path. The script will put the final output in that folder.

set -euo pipefail

program=$(basename "$0")

function usage() {
    echo "usage: $program input output"
    echo "where:"
    echo "    output1  path for v1.0 of the API"
    echo "    output2  path for v2.0 of the API"
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

# To prevent Python from being annoying with imports, cd into the folder
pushd "$dir"

# Run allergen scraper
echo "Scraping allergens"
command="$dir/allergens.py $output2"
# shellcheck disable=2086
eval ${command}

# Run scraper
echo "Scraping all the menus"
command="$dir/menu.py $output2"
# shellcheck disable=2086
eval ${command}

echo "Applying manual changes"
command="$dir/menu_manual.py $output2"
# shellcheck disable=2086
eval ${command}

echo "Scraping sandwiches"
command="$dir/sandwiches.py $output2"
# shellcheck disable=2086
eval ${command}
# Symlink old file for compatibility reasons
rm -f "$output2/sandwiches.json"
ln -s "$output2/sandwiches/static.json" "$output2/sandwiches.json"

echo "Finding all the desserts"
command="$dir/cafetaria.py $output2"
# shellcheck disable=2086
eval ${command}

popd

echo "Resto scraper ran successfully."
