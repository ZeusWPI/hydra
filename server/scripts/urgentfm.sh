#!/usr/bin/env bash

# Get the current Urgent.fm programme.
# This is run periodically.
# This will be run in the pipenv environment.

set -euo pipefail

OUTPUT_DIRECTORY="../api/urgentfm"

cd ../src/

pipenv run python3 urgentfm.py ${OUTPUT_DIRECTORY}

cd ../scripts/

rsync -a ${OUTPUT_DIRECTORY} ~/public/api/2.0/urgentfm/