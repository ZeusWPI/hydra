#!/usr/bin/env bash

# Validate association-related items.
# This script will be run from in the "tests" directory.

# Check the syntax of the special events.
./validators/json.sh "../api/association/special_events.json" "../api/schema/special_event.json"

# Return the status code of the validator.
exit $?