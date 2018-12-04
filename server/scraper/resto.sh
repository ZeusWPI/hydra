#!/usr/bin/env bash
#
# Run resto scraper: run the scraper, save the data and sync it with the public.
#
# Arguments:
#   git   Path to git repo with historic data
#   api   Public API path
#

set -euo pipefail

if [[ $# -lt 3 ]]; then
    echo "error: operands are required" >&2
    exit 1
fi

SOURCE="${BASH_SOURCE[0]}"
while [[ -h "$SOURCE" ]]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
dir="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"

command="$dir/resto/all.sh $1/1.0/ $1/2.0"
"$command"

# Copy to correct server
rsync -a "$1/1.0/" "$2/1.0/resto/"
rsync -a "$1/2.0/" "$2/2.0/resto/"

date=$("+%Y-%m-%d")
cd "$1"
git add .
git commit -m "New data from scraping on $date"
git push

