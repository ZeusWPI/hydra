#!/usr/bin/env bash

python scraper.py
rsync -a resto/* ~/public_html/resto
