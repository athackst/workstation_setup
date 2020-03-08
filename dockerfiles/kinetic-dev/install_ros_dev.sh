#!/bin/bash

set -e

sudo apt-get update
sudo apt-get install -y \
    python-catkin-pkg \
    python-catkin-tools \
    python-rosdep \
    python-rosinstall \
    python-rosinstall-generator \
    python-wstool \
    python3-pip \
    python3-yaml \
    ros-$ROS_DISTRO-catkin \
    build-essential \
    bash-completion \
    git \
    vim
sudo pip3 install rospkg catkin_pkg

sudo rosdep init
rosdep update


