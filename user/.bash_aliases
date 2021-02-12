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
function mkdocs_simple() {
    local port=${1:-"8000"}
    docker run --rm -p ${port}:8000 -v ${PWD}:/docs --user $(id -u):$(id -g) athackst/mkdocs-simple-plugin 
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
  docker run -it --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -u ros athackst/ros:noetic-gazebo gazebo
}
