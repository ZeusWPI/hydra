#!/usr/bin/env bash

set -euo pipefail

python3 schamper.py
rsync -a schamper ~/public/api/1.0
