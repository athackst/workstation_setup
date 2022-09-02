#!/bin/bash

sudo apt-get update
sudo apt-get install -y gh bash-completion
eval "$(gh completion -s bash)"
