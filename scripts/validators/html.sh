#!/usr/bin/env bash

set -euo pipefail

# Validate HTML/CSS files.
# This validator requires the Python package html5validator.
# See https://github.com/svenkreiss/html5validator.
# This package also requires Java to be installed.
#
# This script accepts arguments:
#   1. The location of the folder containing HTML/CSS files to validate (recursive).

if [[ $# -lt 1 ]]; then
    echo "Missing parameters." >&2
    echo "Use: $0 folder" >&2
    exit 2
fi

if [[ ! -d "$1" ]]; then
    echo "The input directory '$1' is not a valid path." >&2
    exit 2
fi

if ! command -v 'java' &> /dev/null; then
    echo "$0 requires java to be installed." >&2
    exit 4
fi

if ! command -v 'html5validator' &> /dev/null; then
    echo "$0 requires the Python package html5validator to be installed." >&2
    exit 4
fi

echo "Checking $1..."
html5validator --root "$1" --also-check-css

# Return the exit code
exit $?