source /opt/ros/crystal/setup.bash

function ros2_dev() {
    docker run -it --rm --volume $HOME:$HOME --name ros2_dev athackst/ros2:crystal-dev bash
}
