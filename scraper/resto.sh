#!/usr/bin/env bash

# Update symlink
rm resto/week
ln -s menu/`date +%Y` resto/week

# Run scraper
python resto.py
#rsync -a resto ~/public/api/1.0
