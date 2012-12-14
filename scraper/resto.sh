#!/usr/bin/env bash

python resto.py
rsync -a resto ~/public/api/1.0
