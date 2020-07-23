title() {
  ORIG=$PS1
  TITLE="\e]2;$@\a"
  PS1=${ORIG}${TITLE}
}

zipall() {
  for dir in *
  do
    if [[ -d $dir ]]
    then
      zip -r $dir.zip $dir
    fi
  done
}

maxlength() {
  maxlen=0
  for dir in $@
  do
    curlen=${#dir}
    if [[ $curlen -gt $maxlen ]]
    then
      maxlen=$curlen
    fi
  done
  echo $maxlen
}

BLACK="\e[30m"
RED="\e[31m"
GREEN="\e[32m"
LTGREEN="\e[92m"
YELLOW="\e[33m"
BLUE="\e[34m"
LTBLUE="\e[94m"
MAGENTA="\e[35m"
CYAN="\e[36m"
WHITE="\e[37m"
UNSET="\e[0m"

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
  g_del() {
    git branch -D $1 2>/dev/null && echo "Deleted local branch $1"
    git push -d origin $1 2>/dev/null && echo "Deleted remote branch $1"
  }
  __git_complete g_del _git_branch
  _git_del() {
    _git_branch
  }
  # Get the status of the current branch
  alias g_status="git status -s"
  # Add changes into the current branch
  alias g_add="git add -u"
  # Commit the changes in the changeref
  alias g_commit="git commit"
  # Push the current changes to a remote branch, matching names
  g_pr() {
    branch=`git name-rev --name-only HEAD`
    remote=`git config "branch.${branch}.remote" || echo "origin"`
    echo "pushing to: $remote $branch"
    git push $remote $branch -u
  }
  # Sync the local branches with the remote
  g_sync() {
    git fetch -p
    git prune
  }
  # Scan all local branches for changes
  g_scan() {
    branchname=$(git rev-parse --abbrev-ref HEAD)
    # get max length of branch name
    local maxlen=$(maxlength $(git for-each-ref --format="%(refname:short)" refs/heads))
    maxlen=$(($maxlen+2))
    git for-each-ref --format="%(refname:short) %(upstream:short)" refs/heads | \
    while read local_ref remote_ref
    do
      remote_status=""
      if [ -z "$remote_ref" ]
      then
        remote_status="${RED}!!${UNSET}"
        remote_ref="${BASE_BRANCH}"
      fi
      git rev-list --left-right ${local_ref}...${remote_ref} -- 2>/dev/null >/tmp/git_upstream_status_delta || continue
      RIGHT_AHEAD=$(grep -c '^>' /tmp/git_upstream_status_delta)
      status=""
      if [ $RIGHT_AHEAD -ne 0 ]
      then
        status="$status${RED}($RIGHT_AHEAD)<--|${UNSET}"
      fi
      LEFT_AHEAD=$(grep -c '^<' /tmp/git_upstream_status_delta)
      if [ $LEFT_AHEAD -ne 0 ]
      then
        status="$status${YELLOW}|-->($LEFT_AHEAD)${UNSET}"
      fi
      if [ -z "$status" ]
      then
        status="${LTGREEN}ok${UNSET}"
      fi
      branch_status=""
      if [[ $local_ref == $branchname ]]
      then
        local_ref="*"$local_ref
        branch_status="$(g_status)"
      fi
      printf "%-${maxlen}s [$status] $remote_status\n" $local_ref
      if [ ! -z "$branch_status" ]
      then
        printf "${RED}%s${UNSET} %s\n" $branch_status
      fi
    done
  }
  
  # Remove branches that have been squashed on the remote
  g_dsquashed() {
    i=0
    git fetch
    git remote prune origin
    for branch in $(git for-each-ref refs/heads/ "--format=%(refname:short)")
    do
      mergeBase=$(git merge-base $BASE_BRANCH $branch)
      if [ -z $mergeBase ]
      then
        continue
      fi
      mergeStatus=$(git cherry $BASE_BRANCH $(git commit-tree $(git rev-parse $branch^{tree}) -p $mergeBase -m _))
      case $mergeStatus in
        "-"*)
          i=$(expr $i + 1)
          git branch -D $branch
        ;;
      esac
    done
    echo "Deleted $i branches"
  }
  
  # Scan the branches of all repositories in a folder
  g_scanall() {
    vcs custom -n --git --args fetch . >/dev/null
    for dir in $(find . -name '.git' -printf "%h\n" | sort -u)
    do
      if [[ -d $dir ]]
      then
        printf "${LTBLUE}=== ${dir} ===${UNSET}\n"
        (cd $dir; g_scan)
        printf "\n"
      fi
    done
  }
  
  g_fetchall() {
    vcs custom -n --git --args fetch . >/dev/null
  }
  
  # Get a short status of all repositories in a folder.
  g_statusall() {
    detail=0
    case $1 in
      "-d")  detail=1;;
      *)  ;;
    esac
    g_fetchall
    # Find the longest directory name
    maxlen=$(maxlength $(find . -name '.git' -printf "%h\n" | sort -u))
    
    # Print the current branch of each directory
    for dir in $(find . -name '.git' -printf "%h\n" | sort -u)
    do
      if [[ -d $dir ]]
      then
        branchname=$(git -C $dir rev-parse --abbrev-ref HEAD)
        status=$(git -C $dir status -s)
        printf "%-${maxlen}s: ${branchname} " $dir
        if [[ -z $status ]]
        then
          printf "[${LTGREEN}ok${UNSET}]"
        else
          printf "[${RED}!!${UNSET}]"
          if [ $detail -ne 0 ]
          then
            printf "\n\t${RED}%s${UNSET} %s" $status
          fi
        fi
        printf "\n"
      fi
    done
  }
  
  g_setall() {
    if [[ $# -ne 1 ]]
    then
      echo "Usage: `basename $0` <branchname>"
      return
    fi
    desired=$1
    # Get the latest refs from remote
    g_fetchall
    # Find the longest directory name
    maxlen=$(maxlength $(find . -name '.git' -printf "%h\n" | sort -u))
    # Checkout the desired branch, if it exists
    for dir in $(find . -name '.git' -printf "%h\n" | sort -u)
    do
      current=$(git -C $dir rev-parse --abbrev-ref HEAD)
      error=""
      # If branch exists
      if [[ $(git -C $dir branch -a | grep "$desired" | wc -l) -ne 0 ]]
      then
        # If not already on desired branch
        if [[ $current != $desired ]]
        then
          git -C $dir checkout -q $desired
          # If the checkout was not successful
          if [[ $(git -C $dir rev-parse --abbrev-ref HEAD) != $desired ]]
          then
            error="${RED}!!${UNSET}"
          fi
        fi
      fi
      # print the branches
      branchname=$(git -C $dir rev-parse --abbrev-ref HEAD)
      printf "%-${maxlen}s: ${branchname} ${error}\n" $dir
    done
  }
  
fi

########################
# workspaces
########################
if [ -d $HOME/.workspace ]; then
  for d in $HOME/.workspace/*/; do
    ws=$(basename $d)
    input='$1'
    num_input='$#'
    source /dev/stdin << EOF
function create_${ws}() {
  if [ ${num_input} -eq 0 ]; then
    echo "Usage: create_${ws} <name>";
    return 1;
  fi
  cp -r $d/. ${input};
};
EOF
  done
fi

########################
# mkdocs
########################
function mkdocs_start() {
  docker run --rm -it --network=host -v ${PWD}:/docs --user $(id -u):$(id -g) -e HOME=/tmp -e PATH=/tmp/.local/bin:$PATH --name mkdocs_simple athackst/mkdocs-simple-plugin $@
}
