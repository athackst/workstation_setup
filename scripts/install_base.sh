#/bin/sh
set -e

# setup sources
sudo apt-get update

sudo apt-get install -y \
  bash-completion \
  build-essential \
  cmake \
  curl \
  git \
  git-lfs \
  make \
  pass \
  python3-pip \
  snapd \
  software-properties-common \
  ssh \
  wget

sudo apt-get install -y python-is-python3
sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1
pip install -U pip
