#!/usr/bin/env bash

set -euo pipefail

python2 schamper.py
rsync -a schamper ~/public/api/1.0
