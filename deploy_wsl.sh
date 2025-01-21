#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

$DIR/install/base.sh
$DIR/install/gh.sh

cd ${DIR}/scripts
pip install .

$DIR/dotfiles/install.sh -y
