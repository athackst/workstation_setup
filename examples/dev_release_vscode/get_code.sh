#!/bin/bash
set -e

mkdir -p src
vcs import < .rosinstall src
