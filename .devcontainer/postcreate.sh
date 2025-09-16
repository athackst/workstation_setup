#!/bin/bash
set -e

setup/base.sh
setup/gh.sh

mkdir -p /tmp/docs

cd scripts
pip install -r requirements.txt
pip install .
