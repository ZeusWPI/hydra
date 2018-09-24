#!/usr/bin/env bash

# Run the Schamper scraper and synchronise the output directory.
# This is run periodically.

set -euo pipefail

OUTPUT_DIRECTORY="../api/schamper"

cd ../src/

echo "Reading Schamper articles..."
pipenv run python3 schamper.py ${OUTPUT_DIRECTORY}

cd ../scripts/

echo "Moving to web..."
rsync -a ${OUTPUT_DIRECTORY} ~/public/api/1.0/schamper/