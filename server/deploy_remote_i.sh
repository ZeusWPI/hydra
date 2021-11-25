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

set -euxo pipefail

if [[ $# -lt 2 ]]; then
    echo "error: source and target operands are required" >&2
    exit 1
fi

prefix=$(realpath -s "$2")

# Create folders
mkdir -p "$prefix/deployment/$1/scraper"
mkdir -p "$prefix/deployment/$1/public"
mkdir -p "$prefix/deployment/$1/restodata"

############################
# Install or update py-env #
############################

# First, check if py-env is installed and available on the path.
if ! command -v pyenv &>/dev/null; then
  echo "Py-env is not present, installing..."

  # Install py-env (specific version to have reproducible builds)
  curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/0a5ac813ba1ed660b201005f19be1e6a386d9ed5/bin/pyenv-installer | bash

  # Add it to the path
cat >>~/.bash_profile <<'EOL'
export PATH="~/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
EOL

  # shellcheck source=/dev/null
  source ~/.bash_profile
else
  echo "Py-env is installed, updating..."
  pyenv update
fi

pyenv install -s 3.9.4
pyenv global 3.9.4

# Create venv environment
python -m venv "$prefix/venv"
