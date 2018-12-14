#!/usr/bin/env bash
#
# Part of the deployment process. Executes on the deployment server.
#
# This script is part II of II that runs on the server. When updating this script,
# do NOT forget to update the other parts as well.
#
# Arguments:
#   source  Name of the folder containing the new deployment (on the remote server)
#   target  Target folder for the deployment. When in doubt, use "~".
#   remote  True if using remote, false otherwise

set -euo pipefail

if [[ $# -lt 3 ]]; then
    echo "error: source, target and remote operands are required" >&2
    exit 1
fi

remote="$3"

prefix=$(realpath -s "$2")

# Where the scraper scripts will be copied to
scraper="$prefix/deployment/$1/scraper"
# Where the public data will reside
public="$prefix/deployment/$1/public"
# Where the resto data will be kept
historic="$prefix/deployment/$1/restodata"
# Where the public api data will be kept
api="$public/api"
# Where the website goes
website="$public/website"

# Activate venv
. "$prefix/venv/bin/activate"

# Install python
pip install -r "$scraper/requirements.txt"

# Set up historic resto data
git clone "ssh://git@git.zeus.gent:2222/hydra/data.git" "$historic"

# Run urgent.fm
"$scraper/urgentfm.py" "$api/2.0/urgentfm/"

# Run schamper
"$scraper/schamper.py" "$api/1.0/schamper/"

# Run resto
"$scraper/resto.sh" "$historic" "$api" "$remote"

echo "Setting up cron..."
cron="$scraper/hydra.cron"

# Path to activate venv
venv=". \"$prefix/venv/bin/activate\""

cat << EOF > "$cron"
# Run resto scraper every day at 10 am
0 10 * * *    ${venv} && ${scraper}/resto.sh    ${historic} ${api}   >> ${prefix}/log/resto-scraper.log
# Run schamper scraper every day at 9 am
0 9 * * *     ${venv} && ${scraper}/schamper.py ${api}/1.0/schamper/ >> ${prefix}/log/schamper-scraper.log
# Run urgent.fm scraper every half our, at 3 offset (e.g. 15:03, 15:33, 16:03)
# A programma normally ends at an hour (e.g. 17:00), but to be sure the website has updated, wait 3 minutes.
3-59/30 * * * *  ${venv} && ${scraper}/urgentfm.py ${api}/2.0/urgentfm/ >> ${prefix}/log/urgentfm-scraper.log
EOF

# Map the API and server endpoint to the new data
# DO NOT link the full public folder; it contains other data.
# Todo: we can do this if we include the OAuth redirect in the repo (as we should)
ln -sfn "$api" "$prefix/public/api"
ln -sfn "$website" "$prefix/public/website"
crontab "$cron"

echo "Deployment complete."
