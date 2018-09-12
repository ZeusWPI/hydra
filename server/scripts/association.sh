#!/usr/bin/env bash

# Produce the association logos and sync them.
# This is run on deployment only.

set -exuo pipefail

mkdir -p ../api/association/
mkdir -p ../api/association/logo
# Remove any old logos
rm ../api/association/logo/*

# First, copy the special events to the output folder.
cp -a ../src/association/special_events.json ../api/association/

# Create the logos in the correct dimension using image magick
MAX_SIZE_PX=300
LOGO_INPUT_GLOB="../src/association/logo/*.png"

# Not currently used
# It is not necessary to change all images. We try to use git to be intelligent.
# First, find the images we deleted in the last commit.
# TO_REMOVE=$(git log -1 --name-only --oneline --pretty=format: scripts/)
# The above does work, but we cannot easily find when the last pull request was, making it useless.

for logo in ${LOGO_INPUT_GLOB}; do
    filename=$(basename ${logo})
    convert ${logo} -resize "${MAX_SIZE_PX}x${MAX_SIZE_PX}" "../api/association/logo/$filename"
done

mkdir -p ~/public/api/2.0/association/
rsync -a ../api/association/ ~/public/api/2.0/association/