#!/usr/bin/env bash

# Deploy from Travis

set -euo pipefail

# TODO: get credentials

# Log on to King as the Hydra user
ssh hydra@zeus.ugent.be -p 2222

# Pull the repo
cd app
git pull

# Execute the deployment script
cd server/scripts
./install.sh