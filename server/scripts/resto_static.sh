#!/usr/bin/env bash

# Create the static data for the resto API.
# This script is run on deployment only.

set -euo pipefail

# Copy the file to the output directory.
cp ../src/resto/meta.json ../api/resto/2.0/

# This file is rsynced when the period scraper is run.
