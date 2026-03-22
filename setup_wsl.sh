#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

$DIR/setup/base.sh
$DIR/setup/gh.sh

$DIR/install.sh
