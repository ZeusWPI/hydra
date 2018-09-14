#!/usr/bin/env bash

# Installs the Hydra Web Services (HWS)
# This is run on every deployment; it makes sure everything is set up correctly.
# TODO: historical data is not saved nor managed by the deployment; if you erase the server, you lose all data.
# The only scraper that currently produces historical data is the resto scraper.
# Perhaps we can add a new git repository that contains the resto data?
# We can add it as a submodule to this repo. Every time the scraper runs, we would commit and push the new data.
# The deployment script can then update the git modules when deploying to add the historical data back.
# Some questions remain about this approach; mainly if this would not introduce too much overhead?

set -exuo pipefail

# 1. Set up Python tools
cd ../src/
pip install --user pipenv
pipenv install --ignore-pipfile

echo "Installed Python environment. Using pipenv run {command} from now on."
cd ../scripts
echo "Creating static data..."

# 2. Run the scripts for static data.
./redirect.sh
./website.sh
./association.sh
./info.sh

# 3. Set up the cron jobs for the scrapers
echo "Setting up cron jobs..."
crontab < crontab.txt

# Done!
echo "Hydra Web Services were installed successfully."