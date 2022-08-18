#!/bin/bash

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
sudo apt-add-repository https://cli.github.com/packages
sudo apt-get update
sudo apt-get install -y gh bash-completion
eval "$(gh completion -s bash)"
