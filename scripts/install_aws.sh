#!/bin/bash
set -e

sudo apt-get install -y python3-pip

pip3 install awscli --upgrade --user

echo "export PATH=/home/athackst/.local/bin:$PATH" >> ~/.bash_aliases

aws configure
