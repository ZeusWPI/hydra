#!/usr/bin/env bash

# Validate HTML/CSS files.
# This validator requires the Python package html5validator.
# See https://github.com/svenkreiss/html5validator.
# This package also requires Java to be installed.
#
# This script accepts arguments:
#   1. The location of the folder containing HTML/CSS files to validate (recursive).

if ! command -v 'java' >/dev/null 2>&1; then
    echo >&2 "Install Java first."
    exit 1
fi

if ! command -v 'html5validator' >/dev/null 2>&1; then
    echo >&2 "Run 'pip install html5validator' to install the HTML validator."
    exit 1
fi

echo "Checking $1..."
html5validator --root "$1" --also-check-css

# Return the exit code
exit $?