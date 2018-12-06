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

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "error: source and target operands are required" >&2
    exit 1
fi

prefix=$(realpath -s "$2")

# Where the scraper scripts will be copied to
scraper="$prefix/deployment/$1/scraper"
# Where the public data will reside
public="$prefix/deployment/$1/public"
# Where the resto data will be kept
historic="$prefix/deployment/$1/restodata"
# Where the public api data will be kept
api="$public/api"

# Activate venv
. "$prefix/venv-scraper/bin/activate"

# Install python
pip install -r "$scraper/requirements.txt"

# Set up historic resto data
git clone "ssh://git@git.zeus.gent:2222/hydra/data.git" "$historic"

# Run urgent.fm
"$scraper/urgentfm.py" "$api/2.0/urgentfm/"

# Run schamper
"$scraper/schamper.py" "$api/1.0/schamper/"

# Run resto
"$scraper/resto.sh" "$historic" "$api"

cron="$scraper/hydra.cron"

# Path to activate venv
venv=". \"$prefix/venv-scraper/bin/activate\""

cat << EOF > "$cron"
10 0 * * 0    ${venv} && ${scraper}/resto.sh    ${historic} ${api}   >> ${prefix}/log/resto-scraper.log
5 * * * *     ${venv} && ${scraper}/schamper.py ${api}/1.0/schamper/ >> ${prefix}/log/schamper-scraper.log
*/15 * * * *  ${venv} && ${scraper}/urgentfm.py ${api}/2.0/urgentfm/ >> ${prefix}/log/urgentfm-scraper.log
EOF

# Switch to new deployment
ln -sf "$public" "$prefix/public"
crontab "$cron"
