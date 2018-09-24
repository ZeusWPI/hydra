#!/usr/bin/env bash

# Produce the info-related stuff.
# This script is run on deployment only.

set -euo pipefail

# Copy information stuff:
#  1. Copy the whole directory
#  2. Copy actual Dutch stuff to the root for backwards compatibility
# Since this is static data, no need to copy it to the output folder first.
rsync -a ../src/info/ ~/public/api/2.0/info/
rsync -a ../src/info/nl/ ~/public/api/2.0/info/

# Ugly replace to fix CSS in compat file
sed -i 's;<link href="../webview.css" rel="stylesheet" type="text/css"/>;<link href="webview.css" rel="stylesheet" type="text/css"/>;' ~/public/api/2.0/info/info-fietsen.html
