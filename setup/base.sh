#!/bin/sh
set -eu

sudo apt-get update

sudo apt-get install -y --no-install-recommends \
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
  python3-venv \
  pipx \
  snapd \
  software-properties-common \
  openssh-client \
  wget

export PATH="$HOME/.local/bin:$PATH"

if pipx list --short | grep -qx autopep8; then
  pipx upgrade autopep8
else
  pipx install autopep8
fi
