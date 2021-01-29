if [ -f /usr/share/bash-completion/completions/git ]; then
  source /usr/share/bash-completion/completions/git
fi
if [ -f /etc/profile.d/git-prompt.sh ]; then
  source /etc/profile.d/git-prompt.sh
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

# Make a new branch, and check it out
g_mk() {
  BASE_BRANCH=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
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
alias g_amend="git add -u; git commit --amed --no-edit"
# Commit the changes in the changeref
alias g_commit="git commit"
# Update branch on remote to match local
g_up() {
  branch=`git name-rev --name-only HEAD`
  remote=`git config "branch.${branch}.remote" || echo "origin"`
  echo "pushing to: $remote $branch"
  git push $remote $branch -u --force
}
# Sync the local branch with the remote
g_sync() {
  git fetch -p
  BASE_BRANCH=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
  git rebase origin/${BASE_BRANCH}
}
# Scan all local branches for changes
g_scan() {
  git fetch -p
  BASE_BRANCH=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
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
    git rev-list --left-right ${local_ref}...${remote_ref} -- 2>/dev/null >/tmp/git_upstream_status_delta
    MISSING_REMOTE=$(grep -c '>fatal' /tmp/git_upstream_status_delta)
    if [ $MISSING_REMOTE -ne 0 ]
    then
      remote_status="${RED}!!${UNSET}"
    fi
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
      branch_status="$(git status -s)"
    fi
    printf "%-${maxlen}s [$status] $remote_status\n" $local_ref
    if [ ! -z "$branch_status" ]
    then
      printf "${RED}%s${UNSET} %s\n" $branch_status
    fi
  done
}

# Remove branches that have been squashed on the remote
g_prune() {
  i=0
  git fetch
  git remote prune origin
  BASE_BRANCH="origin/"$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
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
