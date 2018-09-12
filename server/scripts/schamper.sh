#!/usr/bin/env bash

# Run the Schamper scraper and synchronise the output directory.
# This is run periodically.

set -euo pipefail

OUTPUT_DIRECTORY="../api/schamper"

echo "Reading Schamper articles..."
python3 ../src/schamper.py ${OUTPUT_DIRECTORY}

echo "Moving to web..."
rsync -a ${OUTPUT_DIRECTORY} ~/public/api/1.0/schamper/