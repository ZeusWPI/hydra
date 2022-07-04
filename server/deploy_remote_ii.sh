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

# Where deployments are located
deployment="$prefix/deployment"
# Where the scraper scripts will be copied to
scraper="$deployment/$1/scraper"
# Where the public data will reside
public="$deployment/$1/public"
# Where the resto data will be kept
historic="$deployment/$1/restodata"
# Where the public api data will be kept
api="$public/api"
# Where the website goes
# shellcheck disable=SC2034
website="$public/website"

# Activate venv
# shellcheck source=/dev/null
. "$prefix/venv/bin/activate"

# Install python
pip install -r "$scraper/requirements.txt"

# Set up historic resto data
git clone "ssh://git@git.zeus.gent:2222/hydra/data.git" "$historic"

# Run urgent.fm
# This is a non-critical scraper, so allow failure. Otherwise deploy is blocked.
"$scraper/urgentfm.py" "$api/2.0/urgentfm/" || true

# Run schamper
# This is a non-critical scraper, so allow failure. Otherwise deploy is blocked.
"$scraper/schamper.py" "$api/1.0/schamper/" || true

# Run news
# This is a non-critical scraper, so allow failure. Otherwise deploy is blocked.
"$scraper/news.py" "$api/2.0/news" || true

# Run resto
"$scraper/resto.sh" "$historic" "$api" "$remote"

echo "Setting up cron..."
cron="$scraper/hydra.cron"

# Path to activate venv
venv=". \"$prefix/venv/bin/activate\""

cat << EOF > "$cron"
# Run resto scraper every day at 10 am
0 10 * * *    ${venv} && ${scraper}/resto.sh    ${historic} ${api}   >> ${prefix}/log/resto-scraper.log
# Run resto scraper every day at 8 pm
0 20 * * *    ${venv} && ${scraper}/resto.sh    ${historic} ${api}   >> ${prefix}/log/resto-scraper.log
# Run schamper scraper every day at 9 am
0 9 * * *     ${venv} && ${scraper}/schamper.py ${api}/1.0/schamper/ >> ${prefix}/log/schamper-scraper.log
# Run news scraper every day at 8 am
0 8 * * *     ${venv} && ${scraper}/news.py ${api}/2.0/news/ >> ${prefix}/log/news-scraper.log
# Run urgent.fm scraper every half our, at 3 offset (e.g. 15:03, 15:33, 16:03)
# A programma normally ends at an hour (e.g. 17:00), but to be sure the website has updated, wait 3 minutes.
3-59/30 * * * *  ${venv} && ${scraper}/urgentfm.py ${api}/2.0/urgentfm/ >> ${prefix}/log/urgentfm-scraper.log
EOF

# Link the public directory to our new deploy.
ln -sfn "$public" "$prefix/public/"
crontab "$cron"

echo "Deployment complete."
echo "Check if we need clean-up..."

# At this point, the deployment is successful, so we can clean up some old deployments.
# First, get an array of all deployments (all directories in the deployment directory).

# The following only works in Bash 4.4, king has Bash 4.3.
# readarray -d '' all_deployments < <(find "$deployment" -regextype posix-egrep -maxdepth 1 -regex ".*/[0-9]{14}$" -print0 | sort -z)
# For now, do this instead:
all_deployments=()
while IFS=  read -r -d $'\0'; do
    all_deployments+=("$REPLY")
done < <(find "$deployment" -regextype posix-egrep -maxdepth 1 -regex ".*/[0-9]{14}$" -print0 | sort -z)

# We keep the current version, and two older version: so total is 3.
keep=3
nr_of_deployments="${#all_deployments[@]}"

# If there are less than 3, nothing needs to be done.
if [[ "$nr_of_deployments" -le "$keep" ]]; then
  echo "Nothing to clean up."
  exit 0
fi

nr_to_remove=$((nr_of_deployments - keep))
echo "Removing $nr_to_remove old deployment(s)..."

to_remove=("${all_deployments[@]::$nr_to_remove}")

for directory in "${to_remove[@]}"; do
  rm -r "$directory"
done

echo "Clean-up done."
