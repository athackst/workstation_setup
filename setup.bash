function ros2_dev() {
    docker run -it --rm --volume $HOME:$HOME --name ros2_dev ros2:crystal_dev bash
}
