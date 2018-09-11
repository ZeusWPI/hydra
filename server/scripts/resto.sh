#!/usr/bin/env bash

# Run the resto scraper and synchronise the output directory.
# This is run periodically.

set -euo pipefail

OUTPUT_DIRECTORY="../api/resto"

# Update symlink.
# This symlink's paths are set to work within the public directory.
rm -f "$OUTPUT_DIRECTORY/1.0/week"
ln -s "menu/$(date +%Y)" "$OUTPUT_DIRECTORY/1.0/week"

# Run scraper
echo "Starting a new scrape of the resto"
python3 "../src/resto.py" "$OUTPUT_DIRECTORY"

echo "Pushing everything to the web"
rsync -a "$OUTPUT_DIRECTORY/1.0/" ~/public/api/1.0/resto/
rsync -a "$OUTPUT_DIRECTORY/2.0/" ~/public/api/2.0/resto/
