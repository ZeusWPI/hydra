#!/usr/bin/env bash
#
# Deploy Hydra server stuff.
#
# Use:
#   resto.sh input output
# Arguments:
#   input   The path to the folder with the source data (server/static/association/)
#   output  The root output path. The script will put the final output in that folder.

set -euo pipefail

program=$(basename "$0")

function usage() {
    echo "usage: $program input output"
    echo "where:"
    echo "    server   path to server folder"
}

if [[ $# -lt 2 ]]; then
    echo "error: input operand is required" >&2
    usage
    exit 1
fi

if [[ ! -d "$1" ]]; then
    echo "error: '$1' is not a valid input directory" >&2
    usage
    exit 2
fi

server=$(realpath -s "$1")

###############################################################################
# Create static data
###############################################################################

output="output"
api="$output/api"

# Check requirements
command="$server/static/requirements.sh"
"$command"

command="$server/static/association.sh $server/static/association/ $api/2.0/association/"
"$command"

command="$server/static/info.sh $server/static/info/ $api/2.0/info/"
"$command"

command="$server/static/resto.sh $server/static/resto/ $api/1.0/resto/ $api/2.0/resto/"
"$command"

command="$server/static/website.sh $server/static/website $output/website/"
"$command"

###############################################################################
# Server setup && add new deploy folder
###############################################################################

# Create folder on server, install python and stuff
folder=$(date '+%Y%m%d%H%M%S')
ssh hydra@king.zeus.be "deploy_new-deploy.sh $folder"

# Copy the files we need
rsync -a "$output" "deployment/$folder/public"
rsync -a "$server/scraper" "deployment/$folder/scraper"

# Finalize install on remote
ssh hydra@king.zeus.be "deploy_remote-install.sh $folder"