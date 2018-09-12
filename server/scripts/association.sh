#!/usr/bin/env bash

# Produce the association logos and sync them.
# This is run on deployment only.

set -exuo pipefail

if [ -d ../api/association/logo ]; then
    # Get the date we last generated the images
    generated=$(stat --format=%Y scripts)
else
    # Set to epoch of zero
    generated=0
    mkdir -p ../api/association/logo
fi

# Get date of most recently modified image in the directory
modified=$(ls src/association/logo/*.png -t | head -n 1 | stat --format=%Y -)

# If the modified date is after the generated date, we must regenerate the images.
# The script will regenerate all images; it is currently not smart enough to find changed images.
if [ ${modified} -ge ${generated} ]; then
    # Generate new images. Start by deleting all existing ones.
    rm ../api/association/logo/*
    # Create the logos in the correct dimension using image magick
    MAX_SIZE_PX=300
    for logo in ../src/association/logo/*.png; do
        filename=$(basename ${logo})
        convert ${logo} -resize "${MAX_SIZE_PX}x${MAX_SIZE_PX}" "../api/association/logo/$filename"
    done
else
    # We still need to remove any logos that were deleted, since this is not detected by the time comparison.
    comm -23 <(ls ../api/association/logo/ | sort) <(ls ../src/association/logo/ | grep "\.png$" | sort) | xargs -I {} rm ../api/association/logo/{}
fi

# Save the generation date as the modified date on the folder
touch ../api/association/logo

# Copy the special events to the output folder.
cp -a ../src/association/special_events.json ../api/association/

mkdir -p ~/public/api/2.0/association/
rsync -a ../api/association/ ~/public/api/2.0/association/