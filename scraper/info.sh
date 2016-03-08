#!/usr/bin/env bash
python3 info.py
rsync -a info ~/public/api/2.0
