#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

$DIR/install/base.sh
$DIR/install/programs.sh
$DIR/install/vscode.sh
$DIR/install/docker.sh
$DIR/install/gh.sh

cd $DIR/install/../programs
pip install .

$DIR/install/user_config.sh
