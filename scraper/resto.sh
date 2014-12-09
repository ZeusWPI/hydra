#!/usr/bin/env bash

# Update symlink
rm resto/1.0/week
ln -s menu/`date +%Y` resto/1.0/week

# Run scraper
python resto.py
rsync -a resto/1.0/ ~/public/api/1.0/resto/
rsync -a resto/2.0/ ~/public/api/2.0/resto/
