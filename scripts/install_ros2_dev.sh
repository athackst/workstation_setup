#!/bin/sh
set -e

# install ROS2 development tools
apt-get update && apt-get install -y \
  bash-completion \
  build-essential \
  cmake \
  git \
  python3-colcon-common-extensions \
  python3-pip \
  python-rosdep \
  python3-vcstool \
  sudo \
  wget

rosdep init && rosdep update

