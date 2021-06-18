if [ -f /usr/share/bash-completion/completions/git ]; then
  source /usr/share/bash-completion/completions/git
elif [ -f /etc/profile.d/git-prompt.sh ]; then
  source /etc/profile.d/git-prompt.sh
else
  return
fi

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

alias g="git"
complete -o default -o nospace -F _git g

_g_base_branch() {
  echo "$(_g_remote)/$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)"
}
_g_current_branch() {
  # Try to use --show-current, otherwise fallback to git branch parsing.
  # This is for compatibility with git versions <2.22
  git branch --show-current 2>/dev/null || git branch | grep -v detached | awk '$1=="*"{print $2}'
}
_g_remote() {
  # The name of the remote host
  git config "branch.${branch}.remote" || echo "origin"
}

# Make a new branch, and check it out
g_mk() {
  git branch $1 $(_g_base_branch) --no-track
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
# Remove a branch from local and remote
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
alias g_amend="git commit --amend --no-edit"
alias g_amend_all="git add -u; git commit --amend --no-edit"
# Commit the changes in the changeref
alias g_commit="git commit"
# Update branch on remote to match local
g_up() {
  branch=$(_g_current_branch)
  remote=$(_g_remote)
  echo "pushing to: $remote $branch"
  git push $remote $branch -u --force
}
# Sync the local branch with the remote
g_sync() {
  git fetch -p
  git rebase $(_g_base_branch)
}
# Scan all local branches for changes
g_scan() {
  git fetch -p
  BASE_BRANCH=$(_g_base_branch)
  # get max length of branch name
  local maxlen=$(maxlength $(git for-each-ref --format="%(refname:short)" refs/heads))
  maxlen=$(($maxlen+2))
  git for-each-ref --format="%(refname:short) %(upstream:short)" refs/heads | \
  while read local_ref remote_ref
  do
    remote_status=""
    if [ -z "$remote_ref" ]
    then
      remote_status="${RED}(missing remote)${UNSET}"
      remote_ref="${BASE_BRANCH}"
    fi
    git rev-list --left-right ${local_ref}...${remote_ref} -- 2>/dev/null >/tmp/git_upstream_status_delta
    MISSING_REMOTE=$(grep -c '>fatal' /tmp/git_upstream_status_delta)
    if [ $MISSING_REMOTE -ne 0 ]
    then
      remote_status="${RED}(unpushed refs)${UNSET}"
    fi
    git rev-list --left-right ${local_ref}...${BASE_BRANCH} -- 2>/dev/null >/tmp/git_upstream_status_delta
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
    if [[ ${local_ref} == $(_g_current_branch) ]]
    then
      local_ref="*"$local_ref
      if [[ $(git status -s) ]]; then 
        branch_status="(Uncommitted changes)"
      fi
    fi
    printf "%-${maxlen}s [$status] $remote_status $branch_status\n" $local_ref
  done
}

# Remove branches that have been squashed on the remote
g_prune() {
  i=0
  git fetch -p
  BASE_BRANCH=$(_g_base_branch)
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
  for dir in $(find . -type d \( -name archive -o -name third_party \) -prune -false -o -name '*.git' -printf "%h\n" | sort -u)
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
  for dir in $(find . -name '.git' -printf "%h\n" | sort -u)
  do
    if [[ -d $dir ]]
    then
      (cd $dir; git fetch)
    fi
  done
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
    error=""
    # If branch exists
    if [[ $(git -C $dir branch -a | grep "$desired" | wc -l) -ne 0 ]]
    then
      # If not already on desired branch
      if [[ $(_g_current_branch)  != $desired ]]
      then
        git -C $dir checkout -q $desired
        # If the checkout was not successful
        if [[ $(_g_current_branch)  != $desired ]]
        then
          error="${RED}!!${UNSET}"
        fi
      fi
    fi
    # print the branches
    printf "%-${maxlen}s: $(_g_current_branch) ${error}\n" $dir
  done
}
