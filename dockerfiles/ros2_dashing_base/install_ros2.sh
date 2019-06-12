#/bin/sh
set -e

# setup sources
sudo apt-get update && sudo apt-get install -y \
  curl \
  gnupg2 \
  lsb-release

curl http://repo.ros2.org/repos.key | sudo apt-key add -

# add repository to sources list
sudo sh -c 'echo "deb [arch=amd64,arm64] http://packages.ros.org/ros2/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list'

export DEBIAN_FRONTEND=noninteractive

sudo apt-get install -y tzdata
sudo ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
sudo dpkg-reconfigure --frontend noninteractive tzdata

# install ROS2 (crystal)
sudo apt-get update && sudo apt-get install -y \
  ros-$ROS_DISTRO-ros-base \
  python3-argcomplete
