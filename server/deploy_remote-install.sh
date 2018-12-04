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
scraper="~/deployment/$1/scraper"
public="~/deployment/$1/public"
historic="~/deployment/$1/historic"
api="$public/api"

# Install python
pip install -r "$public/requirements.txt"

# Set up historic resto data
git clone "ssh://git@git.zeus.gent:2222/hydra/data.git" "$historic"

# Run urgent.fm
command="$scraper/urgentfm.py $api/2.0/urgentfm/"
"$command"

# Run schamper
command="$scraper/schamper.py $api/1.0/schamper/"
"$command"

# Run resto
command="$scraper/resto.sh $historic $api"
"$command"

# Symlink public to new deployment
ln -sf "$public" "~/public"
ln -sf "$scraper" "~/scraper"
ln -sf "$historic" "~/historic"

# Schedule cronjob again
crontab "$scraper/crontab.txt"