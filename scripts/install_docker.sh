#!/bin/bash
set -e

# update the apt repository
sudo apt-get update

# install packages to allow apt to use a repository over HTTPS
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# add Docker's stable repository
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# update the package index again
sudo apt-get update

# install the latest version of Docker CE
sudo apt-get install docker-ce docker-ce-cli containerd.io

# update user permisions
user="$(id -un 2>/dev/null || true)"
sudo usermod -aG docker $user
