#!/usr/bin/env bash
#
# Deploy Hydra server stuff.
#
# Use:
#   deploy.sh server dry
# Arguments:
#   server    The path to the server folder. This is the /server/ folder in the git repo.
#   [dry]     Optional path. If present, the server will be deployed to this path. Otherwise it will be deployed to the server.
ssh_server="hydra@pratchett.ugent.be"

set -euo pipefail

use_remote=false
if [[ $# -eq 2 ]]; then
    use_remote=false
    mkdir -p "$2"
    prefix=$(realpath -s "$2")
else
    use_remote=true
    prefix="~"
fi

function w_ssh() {
    # Execute the script on SSH if present, otherwise not.
    if [[ "$use_remote" == true ]]; then
        # We want $2 to expand on the client side.
        # shellcheck disable=2029
        ssh "$ssh_server" -p 2222 < "$1" "bash -l -s $2"
    else
        eval "$1" "$2"
    fi
}

function w_rsync() {
    if [[ "$use_remote" == true ]]; then
        rsync -az -e 'ssh -p 2222' "$1" "$ssh_server:$2"
    else
        rsync -a "$1" "$2"
    fi
}

program=$(basename "$0")

function usage() {
    echo "usage: $program [server] [dry]"
    echo "where:"
    echo "    [server] path to server folder, default is current path"
    echo "    [dry]    path to local folder for local deployment"
}

if [[ $# -lt 1 ]]; then
    SOURCE="${BASH_SOURCE[0]}"
    while [[ -h "$SOURCE" ]]; do # resolve $SOURCE until the file is no longer a symlink
      DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
      SOURCE="$(readlink "$SOURCE")"
      [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done
    server="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
else
    if [[ ! -d "$1" ]]; then
        echo "error: '$1' is not a valid server directory" >&2
        usage
        exit 1
    fi
    server=$(realpath -s "$1")
fi

###############################################################################
# Create static data
###############################################################################

output="output"
api="$output/api"

# Copy static data
"$server/static/association.sh" "$server/static/association/" "$api/2.0/association/"

"$server/static/info.sh" "$server/static/info/" "$api/2.0/info/"

"$server/static/resto.sh" "$server/static/resto/" "$api/1.0/resto/" "$api/2.0/resto/"

"$server/static/website.sh" "$server/static/website" "$output/website/"

###############################################################################
# Server setup && add new deploy folder
###############################################################################

SOURCE="${BASH_SOURCE[0]}"
while [[ -h "$SOURCE" ]]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
dir="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"

# Create folder on server, install python and stuff
folder=$(date '+%Y%m%d%H%M%S')
w_ssh "$dir/deploy_remote_i.sh" "$folder $prefix"

# Copy the files we need
w_rsync "$output/" "$prefix/deployment/$folder/public/"
w_rsync "$server/scraper/" "$prefix/deployment/$folder/scraper/"

# Finalize install on remote
w_ssh "$dir/deploy_remote_ii.sh" "$folder $prefix $use_remote"
