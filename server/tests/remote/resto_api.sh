#!/usr/bin/env bash
#
# Run the tests for the Hydra Resto API. These tests require the API to be fully built. As such, they are only run
# on deployment. It is probably useful to run this test manually during development.
#
# This test is executed on the server, not the Travis. Therefor, it contains special code to ensure dependencies are
# installed.
#
# Use:
#   resto_api.sh json resto
# Arguments:
#   json  The path to the directory with the JSON schema's.
#   resto   The path to the API output of the resto, v2.

set -euo pipefail

program=$(basename "$0")

function usage() {
  echo "usage: $program server"
  echo "where:"
  echo "    json      path the directory with the json schema's"
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
schema=$(realpath -s "$1")

# Map glob patterns to their schema
# See https://github.com/isaacs/node-glob#glob-primer for glob patterns
declare -A mapping
mapping=(
  ["extrafood.json"]=schema_resto_extra.json
  ["sandwiches.json"]=schema_resto_sandwiches.json
  ["meta.json"]=schema_resto_meta.json
  ["*/menu/??/overview.json"]=schema_resto_menu_overview.json
  ["*/menu/??/????/+(??|?)/+(??|?).json"]=schema_resto_menu_day.json
  ["menu/*/overview.json"]=schema_resto_menu_overview.json # Old path with endpoint
  ["menu/*/????/+(??|?)/+(??|?).json"]=schema_resto_menu_day.json # Old path with endpoint
)

shopt -s extglob
for glob in "${!mapping[@]}"; do
    echo "Checking $glob..."
    if compgen -G "$2/$glob" > /dev/null; then
      ajv -s "$schema/${mapping[$glob]}" -r "$schema/schema_*.json" -d "$2/$glob"
    else
      echo "$glob does not match any files."
    fi
done
