#!/bin/bash
# This script compares the files in the home director with those in workstation_setup/user
# by opening up diffmerge so that changes can be captured in this repo.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

path=$DIR/../user/

find $path -type f | while read F
do
  base_path="$HOME/${F#"$path"}"
  diffmerge -d /dev/null $base_path $F
  status=$?
  if [[ $status -eq 1 ]]; then
    echo "$base_path different"
    diffmerge -i $base_path $F
  elif [[ $status -eq 3 ]]; then
    echo "$base_path doesn't exist"
  fi

done
