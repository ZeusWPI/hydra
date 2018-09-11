#!/usr/bin/env bash

# Produce the association logos and sync them.
# This is run on deployment only.

set -euo pipefail

OUTPUT_FOLDER="../api/association"

# First, copy the special events to the output folder.
cp -a "../src/association/special_events.json" "$OUTPUT_FOLDER"

# Create the logos in the correct dimension using imagemagick
MAX_SIZE_PX=300
LOGO_INPUT_GLOB="../src/association/logo/*.png"

for logo in "$LOGO_INPUT_GLOB"; do
    [ -f "$logo" ] || break
    filename=$(basename "$logo")
    convert "$filename" -resize "${MAX_SIZE_PX}x${MAX_SIZE_PX}" "$OUTPUT_FOLDER/logo/$filename"
done

rsync -a "$OUTPUT_FOLDER" ~/public/api/2.0/association/