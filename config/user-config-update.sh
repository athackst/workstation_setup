#!/bin/bash

# md
# ## user-config-update.sh
#
# This script compares the files in workstation_setup/user with those in the home directory
# by using git diff so that changes can be updated in the home directory.
#
# ### Usage
#
# ```sh
# user-config-update.sh
# ```
#
# /md

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
path="$DIR/user"

find $path -type f | while read F; do
  base_path="${HOME}${F#"$path"}"
  echo "$F <=> $base_path"
  diff -q $F $base_path
  status=$?
  if [[ $status -eq 1 ]]; then
    echo "$base_path different"
    git difftool $F $base_path -y
  elif [[ $status -eq 2 ]]; then
    echo "$base_path doesn't exist"
  fi

done
