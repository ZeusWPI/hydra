#!/usr/bin/env bash

python scraper.py
rsync -a resto ~/public/api/1.0
