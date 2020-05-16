title(){
  ORIG=$PS1
  TITLE="\e]2;$@\a"
  PS1=${ORIG}${TITLE}
}
########################
# bazel shortcus
########################
if [ -f /etc/bash-completion.d/bazel-complete.bash ]; then
  # Set up the default workspace
  export BAZEL_WS=~/bazel_ws
  export BAZEL_BIN_CACHE=~/.bazel-binaries
  # Execute a binary.
  b()
  {
    if [[ "$#" -eq 0 ]]
    then
      echo "Re-initializing bazel binary rule cache ..."
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
        path=$BAZEL_WS/bazel-bin/$(echo $rule | sed -e 's|:|/|' -e 's|//||')
        $path "$@"
        return $?
      fi
    done
    echo "No bazel binary $binary found."
    return 1
  }
  # Tab-complete all bazel binaries.
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

########################
# git shortcus
########################
if [ -f /usr/share/bash-completion/completions/git ]; then
  source /usr/share/bash-completion/completions/git
  
  alias g="git"
  complete -o default -o nospace -F _git g
  
  export BASE_BRANCH="origin/master"
  # Make a new branch, and check it out
  g_mk() {
    git branch $1 $BASE_BRANCH --no-track
    git checkout $@
  }
  # List all of the branches
  g_ls() {
    git branch
  }
  # Change into a new branch
  g_cd() {
    git checkout $@
  }
  __git_complete g_cd _git_branch
  _git_cd() {
    _git_branch
  }
  # Remove a branch from local nad remote
  g_delete() {
    git branch -D $1 2>/dev/null && echo "Deleted local branch $1"
    git push -d origin $1 2>/dev/null && echo "Deleted remote branch $1"
  }
  __git_complete g_delete _git_branch
  _git_delete() {
    _git_branch
  }
  # Get the status of the current branch
  alias g_status="git status"
  # Add changes into the current branch
  alias g_add="git add -u"
  # Commit the changes in the changeref
  alias g_commit="git commit"
  # Push the current changes to a remote branch, matching names
  g_push() {
    feature_name=`git name-rev --name-only HEAD`
    git push origin $feature_name -u
  }
  # Sync the local branches with the remote
  g_sync() {
    git fetch -p
    git prune
    git merge
  }
  # Scan all local branches for changes
  g_scan() {
    git for-each-ref --format="%(refname:short) %(upstream:short)" refs/heads | \
    while read local_ref remote_ref
    do
      remote_status=""
      if [ -z "$remote_ref" ]
      then
        remote_status=" !! "
        remote_ref="${BASE_BRANCH}"
      fi
      status=""
      git rev-list --left-right ${local_ref}...${remote_ref} -- 2>/dev/null >/tmp/git_upstream_status_delta || continue
      RIGHT_AHEAD=$(grep -c '^>' /tmp/git_upstream_status_delta)
      if [ $RIGHT_AHEAD -ne 0 ]
      then
        status="$status($RIGHT_AHEAD)<--|"
      fi
      LEFT_AHEAD=$(grep -c '^<' /tmp/git_upstream_status_delta)
      if [ $LEFT_AHEAD -ne 0 ]
      then
        status="${status}|-->($LEFT_AHEAD)"
      fi
      if [ -z "$status" ]
      then
        status="ok"
      fi
      echo "$local_ref <--> $remote_ref $remote_status [ $status ]"
    done
  }
  # Remove branches that have been squashed on the remote
  g_dsquashed() {
    echo "**WIP**"
    i=0
    git fetch
    git for-each-ref refs/heads/ "--format=%(refname:short)" | \
    while read branch
    do
      mergeBase=$(git merge-base $BASE_BRANCH $branch)
      mergeStatus=$(git cherry $BASE_BRANCH $(git commit-tree $(git rev-parse $branch^{tree}) -p $mergeBase -m _))
      case $mergeStatus in
        "-"*)
          i=$(expr $i + 1)
          echo "squashed: $branch is merged into $BASE_BRANCH and can be deleted"
        ;;
        *)    echo "not squashed: $branch is not merged into $BASE_BRANCH" ;;
      esac
    done
    echo "Deleted $i branches"
  }
fi

########################
# workspaces
########################
if [ -d $HOME/.workspace ]; then
  for d in $HOME/.workspace/*/; do
    ws=$(basename $d)
    source /dev/stdin << EOF
function create_${ws}() {
  if [ $# -eq 0 ]; then
    echo "Usage: create_dashing_ws <name>";
    exit 1;
  fi
  cp -r $d/. $1;
};
EOF
  done
fi

########################
# mkdocs
########################
function mkdocs_simple() {
  docker run --rm -it --network=host -v ${PWD}:/docs --user $(id -u):$(id -g) -e HOME=/tmp -e PATH=/tmp/.local/bin:$PATH athackst/mkdocs-simple-plugin $@
}
