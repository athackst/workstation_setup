set-title(){
  ORIG=$PS1
  TITLE="\e]2;$@\a"
  PS1=${ORIG}${TITLE}
}

function ros2_crystal_dev() {
    docker run -it --rm --volume $HOME:$HOME --name ros2_dev athackst/ros2:crystal-dev bash
}
