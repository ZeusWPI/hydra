#!/usr/bin/env bash
#
# Run the tests for the Hydra Resto API. These tests require the API to be fully built. As such, they are only run
# on deployment. It is probably useful to run this test manually during development.
#
# Use:
#   resto_api.sh server resto
# Arguments:
#   server  The path to the server directory.
#   resto   The path to the API output of the resto, v2.

set -euo pipefail

program=$(basename "$0")

function usage() {
  echo "usage: $program server"
  echo "where:"
  echo "    server    path the server directory in the repo"
  echo "    resto     path the resto api output v2"
}

if [[ $# -lt 2 ]]; then
  echo "error: missing an operand" >&2
  usage
  exit 1
fi

if [[ ! -d "$1" ]]; then
  echo "error: '$1' is not a valid directory" >&2
  usage
  exit 1
fi

if [[ ! -d "$2" ]]; then
  echo "error: '$1' is not a valid directory" >&2
  usage
  exit 1
fi

# Remove trailing slashes
server=$(realpath -s "$1")

# Some utils
tests="$server/tests"

# Map glob patterns to their schema
# See https://github.com/isaacs/node-glob#glob-primer for glob patterns
declare -A mapping
mapping=(
  ["extrafood.json"]=schema_resto_extra.json
  ["sandwiches.json"]=schema_resto_sandwiches.json
  ["meta.json"]=schema_resto_meta.json
  ["menu/*/??/overview.json"]=schema_resto_menu_overview.json
  ["menu/*/??/????/+(??|?)/+(??|?).json"]=schema_resto_menu_day.json
  ["menu/*/overview.json"]=schema_resto_menu_overview.json # Old path with endpoint
  ["menu/*/????/+(??|?)/+(??|?).json"]=schema_resto_menu_day.json # Old path with endpoint
)

shopt -s extglob
for glob in "${!mapping[@]}"; do
    echo "Checking $glob..."
    if compgen -G "$2/$glob" > /dev/null; then
      ajv -s "$tests/${mapping[$glob]}" -r "$tests/schema_*.json" -d "$2/$glob"
    else
      echo "$glob does not match any files."
    fi
done
