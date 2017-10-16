#!/usr/bin/env bash

set -euo pipefail

python3 urgentfm.py
rsync -a urgentfm ~/public/api/2.0
