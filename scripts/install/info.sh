#!/usr/bin/env bash

# First argument is input, second is output.
set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Missing parameters." >&2
    echo "Use: $0 source output" >&2
    exit 2
fi

if [[ ! -d "$1" ]]; then
    echo "The input directory '$1' is not a valid path." >&2
    exit 2
fi

if [[ -d "$2" ]]; then
    rm -r "$2"
fi

echo "Installing info"

# We copy the whole folder into the public folder. (we cannot symlink, see later).
# Note that all *.html files in the root are present for backwards compatibility only.
# We first make sure the source directory has a trailing slash.
source=$(realpath "$1")
if [[ ${source:length-1:1} != "/" ]]; then
    source="$source/"
fi
rsync -a "$source" "$2"

# As the Dutch content used to be available in the root, we must also copy that to that root.
# TODO: investigate if we should just provide a redirect on the nginx level instead; this would make things a lot easier.
rsync -a "${source}nl/" "$2"

# Ugly replace to fix CSS in the compatibility file.
sed -i 's;<link href="../webview.css" rel="stylesheet" type="text/css"/>;<link href="webview.css" rel="stylesheet" type="text/css"/>;' "$2/info-fietsen.html"
