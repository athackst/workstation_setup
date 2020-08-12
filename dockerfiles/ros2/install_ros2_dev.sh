#!/bin/sh
set -e

# install ROS2 development tools
apt-get update
apt-get install -y \
  bash-completion \
  build-essential \
  cmake \
  gdb \
  git \
  python3-colcon-common-extensions \
  python3-pip \
  python3-rosdep \
  python3-vcstool \
  vim \
  wget

apt-get install -y \
  ros-$ROS_DISTRO-ament-lint \
  ros-$ROS_DISTRO-launch-testing \
  ros-$ROS_DISTRO-launch-testing-ament-cmake \
  ros-$ROS_DISTRO-launch-testing-ros 

python3 -m pip install -U autopep8

rosdep init || echo "rosdep already initialized"
