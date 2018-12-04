#!/usr/bin/env bash
#
# Deploy Hydra server stuff.
#
# Use:
#   deploy.sh server dry
# Arguments:
#   server    The path to the server folder. This is the /server/ folder in thr git repo.
#   [dry]     Optional path. If present, the server will be deployed to this path. Otherwise it will be deployed
#             to King.

set -euo pipefail

if [[ $# -eq 2 ]]; then
    use_remote=0
    prefix=$(realpath -s "$2")
else
    use_remote=1
    prefix="~"
fi

function w_ssh() {
    # Execute the script on SSH if present, otherwise not.
    if [[ ${use_remote} ]]; then
        ssh hydra@zeus.ugent.be "$1"
    else
        "$1"
    fi
}

function w_rsync() {
    if [[ ${use_remote} ]]; then
        rsync -aze ssh "$1" "hydra@zeus.ugent.be:$2"
    else
        rsync -a "$1" "$2"
    fi
}

program=$(basename "$0")

function usage() {
    echo "usage: $program input output"
    echo "where:"
    echo "    server   path to server folder"
    echo "    [dry]    path to local folder for local deployment"
}

if [[ $# -lt 1 ]]; then
    echo "error: input operand is required" >&2
    usage
    exit 1
fi

if [[ ! -d "$1" ]]; then
    echo "error: '$1' is not a valid server directory" >&2
    usage
    exit 1
fi

server=$(realpath -s "$1")

###############################################################################
# Create static data
###############################################################################

output="output"
api="$output/api"

# Check requirements
"$server/static/requirements.sh"

"$server/static/association.sh" "$server/static/association/" "$api/2.0/association/"

"$server/static/info.sh" "$server/static/info/" "$api/2.0/info/"

"$server/static/resto.sh" "$server/static/resto/" "$api/1.0/resto/" "$api/2.0/resto/"

"$server/static/website.sh" "$server/static/website" "$output/website/"

###############################################################################
# Server setup && add new deploy folder
###############################################################################

# Create folder on server, install python and stuff
folder=$(date '+%Y%m%d%H%M%S')
w_ssh "deploy_remote_i.sh $folder $prefix"

# Copy the files we need
w_rsync "$output" "$prefix/deployment/$folder/public"
w_rsync "$server/scraper" "$prefix/deployment/$folder/scraper"

# Finalize install on remote
w_ssh "deploy_remote_ii.sh $folder $prefix"