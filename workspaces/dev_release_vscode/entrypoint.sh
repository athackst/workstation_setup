#!/bin/bash

source /opt/ros/dashing/setup.bash

if [ -f "/opt/docker/local_setup.bash" ]; then
    source /opt/docker/local_setup.bash
fi
exec "$@"
