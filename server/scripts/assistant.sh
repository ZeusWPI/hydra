#!/usr/bin/env bash

# Install the assistant stuff.
# This is run on deployment only.

cd ../assistant

echo "Enabling Google Assistant"

# Install it
# Use npm ci after I get someone to upgrade npm on king
npm install