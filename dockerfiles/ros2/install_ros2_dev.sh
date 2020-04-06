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
  pylint \
  python3-colcon-common-extensions \
  python3-pip \
  python-rosdep \
  python3-vcstool \
  vim \
  wget

apt-get install -y \
  ros-$ROS_DISTRO-launch-testing \
  ros-$ROS_DISTRO-launch-testing-ament-cmake \
  ros-$ROS_DISTRO-launch-testing-ros 

python3 -m pip install -U pylint

rosdep init

