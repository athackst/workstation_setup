set-title(){
  ORIG=$PS1
  TITLE="\e]2;$@\a"
  PS1=${ORIG}${TITLE}
}

# Tab-complete all bazel binaries.
export BAZEL_WS=~/bazel_ws
export BAZEL_BIN_CACHE=~/.bazel-binaries
_b()
{
  local cur binaries
  cur="${COMP_WORDS[COMP_CWORD]}"
  if [ $COMP_CWORD -eq 1 ]
  then
    binaries=$(cat $BAZEL_BIN_CACHE | sed 's|^.*[:/]||')
    COMPREPLY=($(compgen -W "${binaries}" -- ${cur}))
  else
    COMPREPLY=()
  fi
  return 0
}
complete -o default -F _b b

# Execute a binary.
b()
{
  if [[ "$#" -eq 0 ]]
  then
    echo Re-initializing bazel binary rule cache ...
    (cd $BAZEL_WS && bazel query 'kind(".*_binary rule", //...) union kind(".*_test rule", //...)' > $BAZEL_BIN_CACHE)
    N="$(cat $BAZEL_BIN_CACHE | wc -l)"
    echo "  ... found ${N} binaries."
    return 0
  fi
  binary="$1"
  shift
  for rule in $(cat $BAZEL_BIN_CACHE)
  do
    rule_binary=$(echo $rule | sed 's|^.*[:/]||')
    if [ "$rule_binary" == "$binary" ]
    then
      echo "Running bazel binary $rule ..."
      path=$NURO_WS/bazel-bin/$(echo $rule | sed -e 's|:|/|' -e 's|//||')
      $path "$@"
      return $?
    fi
  done
  echo "No bazel binary $binary found."
  return 1
}

_my_bb_alias_autocomplete() {
  _bazel__complete_target_stdout "build"
}

export BASE_BRANCH="origin/develop"
g() {
  usage() {
    echo "g [[feature] [push] [delete] [fetch]]"
  }
  if [[ "$#" -eq 0 ]]
  then
    usage
    return 0
  fi
  case $1 in
      feature )               shift
                              _g_feature $@
                              ;;
      push )                  shift
                              _g_push $@
                              ;;
      delete )                shift
                              _g_delete $@
                              ;;
      fetch )                 shift
                              _g_fetch $@
                              ;;
      -h | --help )           shift
                              usage
                              ;;
      * )                     usage
                              ;;
  esac
}

_g_feature() {
  usage() {
    echo "Creates a new branch based off of $BASE_BRANCH"
    echo "Usage: g feature <feature_name>"
  }
  if [[ "$#" -eq 0 ]]
  then
    usage
    return 0
  fi
  case $1 in
    -h | --help )           shift
                            usage
                            return 0
                            ;;
    * )                     shift
                            git branch $1 $BASE_BRANCH --no-track
                            git checkout $1
                            ;;
  esac
}

_g_push() {
  usage() {
    echo "Pushes the current branch to the remote origin with the same name."
    echo "Usage: g push"
  }
  case $1 in
    -h | --help )           shift
                            usage
                            return 0
                            ;;
    * )                     feature_name=`git branch --show-current`
                            git push origin $feature_game -u $@
                            ;;
  esac
}

_g_delete() {
  usage() {
    echo "Deletes local and remote branches of the same name."
    echo "Usage: g delete <branch_name>"
  }
  if [[ "$#" -eq 0 ]]
  then
    usage
    return 0
  fi
  case $1 in
    -h | --help )           shift
                            usage
                            return 0
                            ;;
  esac
  git branch -D $1 
  git push -d origin $1
}

_g_fetch() {
  usage() {
    echo "Fetch the latest from the remote and prune."
    echo "Usage: g fetch"
  }
  case $1 in
    -h | --help )           shift
                            usage
                            return 0
                            ;;
    * )                     git remote prune origin
                            git prune
                            git fetch
                            ;;
  esac
}

_g_custom_autocomplete()
{
    local cur prev

    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case ${COMP_CWORD} in
        1)
            COMPREPLY=($(compgen -W "feature push delete fetch" -- ${cur}))
            ;;
        2)
            case ${prev} in
                delete)
                    branches=$(git branch -l | cut -c3-)
                    COMPREPLY=($(compgen -W "$branches" -- "$2"))
                    ;;
            esac
            ;;
        *)
            COMPREPLY=()
            ;;
    esac
}

complete -o nospace -o default -F _g_custom_autocomplete g
