#!/bin/sh
set -e

# install ROS2 development tools
sudo apt-get update
sudo apt-get install -y \
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

sudo apt-get install -y \
  ros-$ROS_DISTRO-launch-testing \
  ros-$ROS_DISTRO-launch-testing-ament-cmake \
  ros-$ROS_DISTRO-launch-testing-ros 

rosdep init && rosdep update

