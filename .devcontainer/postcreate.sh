#!/bin/bash
set -e

setup/base.sh
setup/gh.sh
setup/mkdocs.sh

cd scripts
pip install -r requirements.txt
pip install .
