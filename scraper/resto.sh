#!/usr/bin/env bash

set -euo pipefail


# Update symlink
rm -f resto/1.0/week
ln -s "menu/$(date +%Y)" resto/1.0/week

# Ensure datadir
mkdir -p "resto/1.0/menu/$(date +%Y)"

# Run scraper
python3 resto.py
rsync -a resto/1.0/ ~/public/api/1.0/resto/
rsync -a resto/2.0/ ~/public/api/2.0/resto/
