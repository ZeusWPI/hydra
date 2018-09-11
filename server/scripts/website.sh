#!/usr/bin/env bash

# Create the website.
# This is only run on deployment.

set -euo pipefail

# Update symlink.
# This symlink's paths are set to work within the public directory.
# We assume the repo is clone in a folder called app.
rm -f "~/public/website/"
ln -s "~/app/server/website/" "~/public/website/"
