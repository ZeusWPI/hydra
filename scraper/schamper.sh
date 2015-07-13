#!/usr/bin/env bash

python2 schamper.py
rsync -a schamper ~/public/api/1.0
