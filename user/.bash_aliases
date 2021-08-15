title() {
  ORIG=$PS1
  TITLE="\e]2;$@\a"
  PS1=${ORIG}${TITLE}
}

zipall() {
  for dir in *; do
    if [[ -d $dir ]]; then
      zip -r $dir.zip $dir
    fi
  done
}

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

__bash_prompt() {
  local terminalpart='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:'
  local gitbranch='` \
        if [ "$(parse_git_branch)" != "" ]; then \
            echo -n "\[\033[0;36m\](\[\033[1;31m\]$(parse_git_branch)" \
            && if git ls-files --error-unmatch -m --directory --no-empty-directory -o --exclude-standard ":/*" > /dev/null 2>&1; then \
                    echo -n " \[\033[1;33m\]✗"; \
            fi \
            && echo -n "\[\033[0;36m\]) "; \
        fi`'
  local lightblue='\[\033[1;34m\]'
  local removecolor='\[\033[0m\]'
  PS1="${terminalpart}${lightblue}\w ${gitbranch}${removecolor}\$ "
  unset -f __bash_prompt
}

__bash_prompt

########################
# bazel shortcus
########################
if [ -f $HOME/.aliases/bazel_aliases.sh ]; then
  source $HOME/.aliases/bazel_aliases.sh
fi

########################
# git shortcus
########################
if [ -f $HOME/.aliases/git_aliases.sh ]; then
  source $HOME/.aliases/git_aliases.sh
fi

########################
# workspaces
########################

# Returns the raw gh auth status displyaing the auth token.
# Doc: https://cli.github.com/manual/gh_auth_status
get_gh_auth_status() {
  gh auth status -t 2>&1
}

# Returns the current user's username from the auth status.
get_gh_username() {
  local auth_status="${1:-}"
  [[ -z "${auth_status}" ]] && auth_status="$(get_gh_auth_status)"
  echo "${auth_status}" |
    sed -E -n 's/^.* Logged in to [^[:space:]]+ as ([^[:space:]]+).*/\1/gp'
}

function create_ros2_ws() {
  if [ -z "$1" ]; then
    echo "Error: Need to provide a name for the workspace!"
    echo "Usage: create_ros2_ws <name>"
    return
  fi
  if get_gh_auth_status; then
    user=$(get_gh_username)
  else
    return
  fi
  gh repo create $1 --template althack/vscode_ros2_workspace --private --include-all-branches
  gh repo clone $user/$1
  cd $1
}

function create_website_ws() {
  if [ -z "$1" ]; then
    echo "Error: Need to provide a name for the workspace!"
    echo "Usage: create_website_ws <name>"
    return
  fi
  if get_gh_auth_status; then
    user=$(get_gh_username)
  else
    return
  fi
  gh repo create $1 --template althack/vscode_website_workspace --private --include-all-branches
  gh repo clone $user/$1
  cd $1
}

########################
# mkdocs
########################
function mkdocs_docker_serve() {
  local port=${1:-"8000"}
  docker run --rm -p ${port}:8000 -v ${PWD}:/docs -e THEME=material -e SITE_DIR="/test" -it althack/mkdocs-simple-plugin:latest
}

function althack_mkdocs() {
  (
    curr_dur=$PWD
    cd /tmp
    rm -fr /tmp/althack.mkdocs/
    git clone -b main --depth 1 --single-branch https://github.com/althack/althack.mkdocs.git &&
      rm -rf althack.mkdocs/.git/
    cp -r $curr_dur/* /tmp/althack.mkdocs/
    cd /tmp/althack.mkdocs
    mkdocs_docker_serve
  )
}

########################
# Github
########################
if command -v gh &> /dev/null; then
  eval "$(gh completion -s bash)"
fi

########################
# ROS
########################
function noetic_gazebo() {
  docker run -it --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -u ros althack/ros:noetic-gazebo gazebo
}
