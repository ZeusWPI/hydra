#!/usr/bin/env bash

# Deploys the Hydra API Application Service (HAAS)
# This is run on every deployment; it makes sure everything is set up correctly.
# TODO: historical data is not saved nor managed by the deployment; if you erase the server, you lose all data.
# The only scraper that currently produces historical data is the resto scraper.
# Perhaps we can add a new git repository that contains the resto data?
# We can add it as a submodule to this repo. Every time the scraper runs, we would commit and push the new data.
# The deployment script can then update the git modules when deploying to add the historical data back.
# Some questions remain about this approach; mainly if this would not introduce too much overhead?

set -euo pipefail

# 1. Set up the virtualenv for Python
# TODO: the script currently assumes a virtual env is available, but we would like this script to set up everything
#       in the future.

# 2. Run the scripts for static data.
./website.sh
./association.sh
./info.sh

# 3. Set up the cron jobs for the scrapers
crontab < crontab.txt

# Done!