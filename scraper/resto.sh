#!/usr/bin/env bash

set -euo pipefail


# Update symlink
rm -f resto/1.0/week
ln -s "menu/$(date +%Y)" resto/1.0/week

# Run scraper
echo "Scraping all the restomenus"
python3 resto.py

echo "Eating all the sandwiches"
python3 sandwiches.py

echo "Finding all the desserts"
python3 cafetaria.py

echo "Pushing everything to the web"
rsync -a resto/1.0/ ~/public/api/1.0/resto/
rsync -a resto/2.0/ ~/public/api/2.0/resto/
