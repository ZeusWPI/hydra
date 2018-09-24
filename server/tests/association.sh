#!/usr/bin/env bash

# Validate association-related items.
# This script will be run from in the "tests" directory.

# Check the syntax of the special events.
./validators/json.sh "../src/association/special_events.json" "../src/schema/special_events.json"

# Return the status code of the validator.
exit $?