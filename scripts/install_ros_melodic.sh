#!/bin/bash

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
sudo apt-get update
sudo apt-get install -y ros-melodic-desktop-full

sudo apt-get install -y python-rosinstall python-rosinstall-generator python-wstool build-essential

#initialize and update rosdep
if [ ! -f "/etc/ros/rosdep/sources.list.d/20-default.list" ]
then
  rosdep init
fi
rosdep update

# add to .bash_aliases if not already there
if ! grep -Fxq "source /opt/ros/melodic/setup.bash" ~/.bash_aliases
then
  echo "adding /opt/ros/melodic/setup.bash to bash_aliases"
  echo "source /opt/ros/melodic/setup.bash" >> ~/.bash_aliases
fi
