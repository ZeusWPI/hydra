#!/usr/bin/env bash
#
# Part of the deployment process.
#
# Arguments:
#   input  Name of the new deployment server

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "error: input operand is required" >&2
    exit 1
fi

# Ensure we are in the home directory
cd ~

# Create folders
mkdir -p "deployment/$1/scraper"
mkdir -p "deployment/$1/public"
mkdir -p "deployment/$1/historic"

# Install py-env
# Very safe, pipe remote files into bash
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

# Update
pyenv update

pyenv global 3.7.1

# Create venv environment
python -m venv ~/venv
