#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

$DIR/scripts/install_base.sh
$DIR/scripts/install_gh.sh

cd ${DIR}/scripts/programs
pip install .

$DIR/scripts/install_user_config.sh
