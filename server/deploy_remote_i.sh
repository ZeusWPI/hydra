#!/usr/bin/env bash
#
# Part of the deployment process. Executes on the deployment server.
#
# This script is part I of II that runs on the server. When updating this script,
# do NOT forget to update the other parts as well.
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

# Add to path if necessary
if ! command -v pyenv &>/dev/null; then
cat >>~/.bash_profile <<'EOL'
export PATH="~/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
EOL
source ~/.bash_profile
fi

pyenv update
pyenv install -s 3.7.1
pyenv global 3.7.1

# Create venv environment
python -m venv "$prefix/venv"
