#!/bin/bash

# md
# ## docker-services-stop
#
# This script compares the files in workstation_setup/user with those in the home directory
# by opening up diffmerge so that changes can be updated in the home directory.[^1]
#
# ### Usage
#
# ```sh
# user-config-update
# ```
#
# [^1]: Location of this project must be in ~/Code
# /md

path="$HOME/Code/workstation_setup/user"

find $path -type f | while read F; do
  base_path="${HOME}${F#"$path"}"
  diff -q $F $base_path
  status=$?
  if [[ $status -eq 1 ]]; then
    echo "$base_path different"
    git difftool $F $base_path
  elif [[ $status -eq 3 ]]; then
    echo "$base_path doesn't exist"
  fi

done
