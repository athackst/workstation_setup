#!/bin/bash

source /opt/ros/crystal/setup.bash

# function build {
#     su - $USER && colcon build --base-paths $1 $@
# }

# env

# echo "building.." && su - $USER && colcon build --base-paths $1 $@

exec "$@"
