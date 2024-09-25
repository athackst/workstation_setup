#!/bin/bash

# md
# ## user-config-diff.sh
#
# This script compares the files in the home directory with those in workstation_setup/user
# by using git diff so that changes can be captured in this repo.
#
# ### Usage
#
# ```sh
# user-config-diff.sh
# ```
#
# /md

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
path="$DIR/user"

find $path -type f | while read F; do
  base_path="${HOME}${F#"$path"}"
  echo "$base_path <=> $F"
  diff -q $base_path $F
  status=$?
  if [[ $status -eq 1 ]]; then
    git difftool $base_path $F -y
  else
    echo "skipping $base_path..."
  fi

done
