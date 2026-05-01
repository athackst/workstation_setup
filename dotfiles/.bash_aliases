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
  gh repo create $1 --template athackst/vscode_ros2_workspace --private --include-all-branches
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
  gh repo create $1 --template athackst/vscode_website_workspace --private --include-all-branches
  gh repo clone $user/$1
  cd $1
}

########################
# mkdocs
########################
function mkdocs_docker_serve() {
  local port=${1:-"8000"}
  docker run --rm -p ${port}:8000 -v ${PWD}:/docs -e INPUT_THEME=material -it althack/mkdocs-simple-plugin:latest
}

function mkdocs_docker_build() {
  docker run --rm -v ${PWD}:/docs -w /docs --user $(id -u):$(id -g) -e INPUT_THEME=material althack/mkdocs-simple-plugin:latest mkdocs_simple_gen --build
}

function mkdocs_docker() {
  docker run --rm -v ${PWD}:/docs -w /docs --user $(id -u):$(id -g) -it althack/mkdocs-simple-plugin:latest /bin/bash
}

function mkdocs_athackst() {
  curr_dir=$PWD
  mkdocs_dir="/tmp/athackst.mkdocs"
  rm -fr ${mkdocs_dir}
  git clone -b main --depth 1 --single-branch https://github.com/athackst/athackst.mkdocs.git ${mkdocs_dir} \
    && rm -rf ${mkdocs_dir}/.git/
  echo "Copying current directory ${curr_dir} to ${mkdocs_dir}"
  rsync -av ./ ${mkdocs_dir}/
  (cd ${mkdocs_dir} && mkdocs_docker_serve)
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

########################
# Docker
########################
function docker-images-update() {
  docker system prune -f
  docker pull ubuntu:24.04
  docker pull mcr.microsoft.com/devcontainers/base:jammy
  docker pull althack/ros2:jazzy-base
  docker pull althack/ros2:jazzy-dev
  docker pull althack/ros2:jazzy-gazebo
  docker pull althack/gz:jetty-dev
  docker pull althack/mkdocs-simple-plugin
}

function docker-services-start() {
  docker run -d -p 5000:5000 --restart=always --name registry registry:2
  docker run -d -p 8123:8000 --restart=always --name notes -v ~/Notes:/docs -e THEME=material -e SITE_DIR="/test" althack/mkdocs-simple-plugin:latest
  docker run -d --restart=always --name watchtower --volume /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --include-restarting --cleanup
}

function docker-services-stop() {
  docker update --restart=no registry
  docker update --restart=no notes
  docker update --restart=no watchtower
}

function docker-services-update() {
  docker run --rm -t --name watchtower-update --volume /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --include-restarting --cleanup --run-once
}

#######################
# HTML Proofer
#######################
function htmlproofer_action() {
	curr_dir="$PWD/$1"
	echo "Running on $curr_dir"
	base_dir=$(basename "$PWD")
	ignore="https://www.linkedin.com/in/allisonthackston,http://sdformat.org,/gazebosim.org/docs/citadel/,https://fonts.gstatic.com,/regex101.com/"
	url_swap="^\/${base_dir}:,^\/dev:,^\/v\d+\.\d+\.\d+:"
	docker run -v ${curr_dir}:/site -e INPUT_IGNORE_URLS=${ignore} -e INPUT_URL_SWAP=${url_swap} althack/htmlproofer:latest
}

##########################
# Aliases
##########################
alias rm='trash -v'
alias ci-bot-athackst='ci-bot setup --token-file "$HOME/.config/tokens/athackst_ci_bot.token"'
alias ci-bot-althack='ci-bot setup --token-file "$HOME/.config/tokens/althack_ci_bot.token"'
alias git-use-althack='git-use althack 73732028+althack@users.noreply.github.com'
alias git-use-athackst='git-use athackst 6098197+athackst@users.noreply.github.com'

###########################
# Autocompletes
###########################
if command -v ci-bot &> /dev/null; then
  eval "$(_CI_BOT_COMPLETE=bash_source ci-bot)"
fi
