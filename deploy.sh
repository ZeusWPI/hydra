#!/usr/bin/env bash

# Deploy from Travis

set -euo pipefail

# Log on to King as the Hydra user
# SSH keys should have been set up by Travis
ssh hydra@zeus.ugent.be -p 2222

# Pull the repo
cd app
git pull

# Update the submodules
git submodule update --recursive --remote


# Execute the deployment script
cd server/scripts
./install.sh