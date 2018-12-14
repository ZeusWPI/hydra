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
    echo "    push      true or false, depending on if you want to push to the repo or not"
}

if [[ $# -lt 2 ]]; then
    echo "error: 2 operands are required" >&2
    usage
    exit 1
fi

if [[ $# -lt 3 ]]; then
    push=true
else
    push="$3"
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

today=$(date +%F)
cd "$internal"
git add .
# The first part prevents git from committing nothing, resulting in an error
git diff-index --quiet HEAD || git commit -m "Scraper: new data from $today"

# Porcelain prevents git from writing non-errors to stderr, resulting in emails
if [[ "$push" == true ]]; then
    git push --porcelain
fi