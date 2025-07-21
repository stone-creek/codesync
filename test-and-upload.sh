#!/bin/bash

set -e

python3 test.py
python3 upload.py --auth=$auth_token