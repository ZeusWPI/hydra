#!/usr/bin/env bash
#
# Part of the deployment process. Executes on the deployment server.
#
# Arguments:
#   source  Name of the new folder for the deployment (on the remote server)
#   target  Target folder for the deployment. When in doubt, use "~".

set -euo pipefail


if [[ $# -lt 2 ]]; then
    echo "error: source and target operands are required" >&2
    exit 1
fi

prefix=$(realpath -s "$2")

# Create folders
mkdir -p "$prefix/deployment/$1/scraper"
mkdir -p "$prefix/deployment/$1/public"
mkdir -p "$prefix/deployment/$1/restodata"

# Install py-env
# Very safe, pipe remote files into bash
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

# Update
pyenv update

pyenv global 3.7.1

# Create venv environment
python -m venv "$prefix/venv-scraper"
