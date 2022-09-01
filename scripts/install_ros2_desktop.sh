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

sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# install ROS2 (dashing)
sudo apt-get update && sudo apt-get install -y \
  ros-$ROS_DISTRO-desktop \
  python3-argcomplete

# install ROS2 development tools
sudo apt-get update && sudo apt-get install -y \
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

#initialize and update rosdep
if [ ! -f "/etc/ros/rosdep/sources.list.d/20-default.list" ]; then
  rosdep init
fi
rosdep update

# add to .bash_aliases if not already there
if ! grep -Fxq "source /opt/ros/$ROS_DISTRO/setup.bash" ~/.bash_aliases; then
  echo "adding ros $ROS_DISTRO to bash_aliases"
  echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bash_aliases
fi

source ~/.bashrc
