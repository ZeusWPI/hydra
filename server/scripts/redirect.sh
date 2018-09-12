#!/usr/bin/env bash

# Create the redirect for Minerva.
# This is only run on deployment.

set -euo pipefail

mkdir -p ~/public/oauth/callback
cp ../src/redirect.html ~/public/oauth/callback/index.html