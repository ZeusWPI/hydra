#!/usr/bin/env bash

# Create the website.
# This is only run on deployment.

set -euo pipefail

# Remove the sym link. Notice the absence of a trailing slash: this is required, otherwise rm cannot delete
# the sym link.
rm -f ~/public/website
# We don't need any processing for the website, so just link it instead of copying.
ln -s ~/app/server/website/ ~/public/
