#!/usr/bin/env bash

# Get the current Urgent.fm programme.
# This is run periodically.

set -euo pipefail

OUTPUT_DIRECTORY="../api/urgentfm"

python3 urgentfm.py ${OUTPUT_DIRECTORY}

rsync -a ${OUTPUT_DIRECTORY} ~/public/api/2.0/urgentfm/