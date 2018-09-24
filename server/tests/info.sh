#!/usr/bin/env bash

# Validate info-related items.
# This script will be run from in the "tests" directory.

# Execute checks.
prefix="../api/info"
./validators/json.sh "$prefix/nl/info-content.json" "../api/schema/info-content.json" &&
./validators/json.sh "$prefix/en/info-content.json" "../api/schema/info-content.json" &&
./validators/html.sh "$prefix"

# Return the status code of the validator.
exit $?