#!/usr/bin/env bash

# Copy information stuff:
# 1. Copy the whole directory
# 2. Copy actual Dutch stuff to the root for backwards compatibility
rsync -a info ~/public/api/2.0
rsync -a info/nl/ ~/public/api/2.0/info

# Ugly replace to fix CSS in compat file
sed -i 's;<link href="../webview.css" rel="stylesheet" type="text/css"/>;<link href="webview.css" rel="stylesheet" type="text/css"/>;' ~/public/api/2.0/info/info-fietsen.html

rsync -a association ~/public/api/2.0
