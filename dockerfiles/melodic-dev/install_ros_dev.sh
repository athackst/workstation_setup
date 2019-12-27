#!/bin/bash

set -e

sudo apt-get update
sudo apt-get install -y \
    python-rosinstall \
    python-rosinstall-generator \
    python-wstool \
    build-essential \
    bash-completion \
    git \
    vim

sudo rosdep init
rosdep update


