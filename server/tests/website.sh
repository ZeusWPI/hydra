#!/usr/bin/env bash

# Validate website.
# This script will be run from in the "tests" directory.

# Execute checks.
./validators/html.sh ../website

# Return the status code of the validator.
exit $?