#!/usr/bin/env bash
#
# Run resto scraper: run the scraper, save the data and sync it with the public.
#
# Arguments:
#   git   Path to git repo with historic data.
#   api   Public API path.
#

set -euo pipefail

program=$(basename "$0")

function usage() {
    echo "usage: $program internal external"
    echo "where:"
    echo "    internal  path the directory containing the historical resto data (git repo)"
    echo "    output    path to the root public output folder for the api"
}

if [[ $# -lt 2 ]]; then
    echo "error: 2 operands are required" >&2
    usage
    exit 1
fi

internal=$(realpath -s "$1")
api=$(realpath -s "$2")
internal_v1="$internal/1.0/"
internal_v2="$internal/2.0/"
api_v1="$api/1.0/resto/"
api_v2="$api/2.0/resto/"

SOURCE="${BASH_SOURCE[0]}"
while [[ -h "$SOURCE" ]]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
dir="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"

"$dir/resto/all.sh" "$internal_v1" "$internal_v2"

# Copy to correct server
rsync -a "$internal_v1" "$api_v1"
rsync -a "$internal_v2" "$api_v2"

date=$("+%Y-%m-%d")
cd "$internal"
git add .
git commit -m "Scraper: new data from $date"
git push
