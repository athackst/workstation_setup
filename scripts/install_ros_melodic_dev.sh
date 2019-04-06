#!/bin/bash

set -e

sudo rosdep init
rosdep update

sudo apt-get install -y python-rosinstall python-rosinstall-generator python-wstool build-essential
