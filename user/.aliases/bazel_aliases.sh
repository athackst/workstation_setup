########################
# bazel shortcus
########################
if [ -f /etc/bash-completion.d/bazel-complete.bash ]; then
  # Set up the default workspace
  export BAZEL_WS=~/bazel_ws
  export BAZEL_BIN_CACHE=~/.bazel-binaries
else
  return
fi
# Execute a binary.
b() {
  if [[ "$#" -eq 0 ]]; then
    echo "Re-initializing bazel binary rule cache ..."
    (cd $BAZEL_WS && bazel query 'kind(".*_binary rule", //...) union kind(".*_test rule", //...)' > $BAZEL_BIN_CACHE)
    N="$(cat $BAZEL_BIN_CACHE | wc -l)"
    echo "  ... found ${N} binaries."
    return 0
  fi
  binary="$1"
  shift
  for rule in $(cat $BAZEL_BIN_CACHE); do
    rule_binary=$(echo $rule | sed 's|^.*[:/]||')
    if [ "$rule_binary" == "$binary" ]
    then
      echo "Running bazel binary $rule ..."
      path=$BAZEL_WS/bazel-bin/$(echo $rule | sed -e 's|:|/|' -e 's|//||')
      $path "$@"
      return $?
    fi
  done
  echo "No bazel binary $binary found."
  return 1
}
# Tab-complete all bazel binaries.
_b() {
  local cur binaries
  cur="${COMP_WORDS[COMP_CWORD]}"
  if [ $COMP_CWORD -eq 1 ]; then
    binaries=$(cat $BAZEL_BIN_CACHE | sed 's|^.*[:/]||')
    COMPREPLY=($(compgen -W "${binaries}" -- ${cur}))
  else
    COMPREPLY=()
  fi
  return 0
}
complete -o default -F _b b

alias bb="bazel build"
_my_bb_alias_autocomplete() {
  _bazel__complete_target_stdout "build"
}
complete -o nospace -F _my_bb_alias_autocomplete bb

alias bt="bazel test"
_my_bt_alias_autocomplete() {
  _bazel__complete_target_stdout "test"
}
complete -o nospace -F _my_bt_alias_autocomplete bb
fi
