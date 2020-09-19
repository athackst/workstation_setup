#!/bin/bash
# This script compares the files in workstation_setup/user with those in the home directory 
# by opening up diffmerge so that changes can be captured in the home directory.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

path=$DIR/../user/

find $path -type f | while read F
do
  base_path="$HOME/${F#"$path"}"
  diffmerge -d /dev/null $F $base_path
  status=$?
  if [[ $status -eq 1 ]]; then
    echo "$base_path different"
    diffmerge -i $F $base_path 
  elif [[ $status -eq 3 ]]; then
    echo "$base_path doesn't exist"
  fi

done
