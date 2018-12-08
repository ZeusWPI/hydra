#!/usr/bin/env bash
#
# Run tests on Travis.
#
# Use:
#   resto.sh input output
# Arguments:
#   input   The path to the folder with the source data (server/static/association/)
#   output  The root output path. The script will put the final output in that folder.

set -euo pipefail

program=$(basename "$0")

function usage() {
    echo "usage: $program [server]"
    echo "where:"
    echo "    [server] path to server folder, default is current path"
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

# Check requirements
"$server/tests/requirements.sh"

# Do tests
"$server/tests/test.sh" "$server"
