#!/bin/bash

# md
# ## docker-services-stop
#
# This script compares the files in the home directory with those in workstation_setup/user
# by opening up diffmerge so that changes can be captured in this repo.[^1]
#
# ### Usage
#
# ```sh
# user-config-diff
# ```
#
# [^1]: Location of this project must be in ~/Code
# /md

path="$HOME/Code/workstation_setup/user"

find $path -type f | while read F; do
  base_path="${HOME}${F#"$path"}"
  diff -q $base_path $F
  status=$?
  if [[ $status -eq 1 ]]; then
    echo "$base_path different"
    git difftool $base_path $F
  elif [[ $status -eq 3 ]]; then
    echo "$base_path doesn't exist"
  fi

done
