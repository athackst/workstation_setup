#!/bin/bash

set -e

docker build -f ./.releasecontainer/Dockerfile -t vscode/ros2:ros2_dashing_vscode .