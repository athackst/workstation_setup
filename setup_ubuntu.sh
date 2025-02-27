#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

$DIR/setup/base.sh
$DIR/setup/programs.sh
$DIR/setup/vscode.sh
$DIR/setup/docker.sh
$DIR/setup/gh.sh

cd $DIR/scripts
pip install .

$DIR/install.sh
