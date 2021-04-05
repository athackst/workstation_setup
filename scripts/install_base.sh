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
  python-is-python3 \
  python3-pip \
  snapd \
  software-properties-common \
  ssh \
  wget &&
  echo "installed packages"
