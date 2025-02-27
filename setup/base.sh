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
  python3 \
  python3-pip \
  snapd \
  software-properties-common \
  ssh \
  wget

# Uncomment if in version of ubuntu that supports both python and python3
# sudo apt-get install -y python-is-python3
# sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1
pip install -U pip
pip install -U autopep8 requests hatch
