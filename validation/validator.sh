#!/usr/bin/env bash

if ! command -v 'ajv' >/dev/null 2>&1; then
    echo >&2 "Run 'npm install -g ajv-cli' to install the json validator."
    exit 1
fi

validate() {
    filename=$(basename -- "$1")
    filename="${filename%.*}"
    echo "Checking $1..."
    ajv test -s "schema/${filename}" -d "$1" --valid
    exit_status=$?
    return ${exit_status}
}

# Add new tests here.

validate '../scraper/info/nl/info-content.json' &&
validate '../scraper/info/en/info-content.json' &&
validate '../scraper/association/special_events.json'

exit $?