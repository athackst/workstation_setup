#!/bin/bash

docker pull ubuntu:20.04
docker pull ubuntu:18.04
docker pull mcr.microsoft.com/vscode/devcontainers/base:0-focal
# kinetic images needed for deepracer
docker pull athackst/ros:kinetic-base
docker pull athackst/ros:kinetic-dev
# Latest ros release
docker pull athackst/ros:noetic-base
docker pull athackst/ros:noetic-dev
docker pull athackst/ros:noetic-gazebo
# Latest ros2 release
docker pull athackst/ros2:foxy-base
docker pull athackst/ros2:foxy-dev
docker pull athackst/ros2:foxy-gazebo
# Latest ignition release
docker pull athackst/ignition:edifice-dev
# Latest mkdocs simple plugin
docker pull athackst/mkdocs-simple-plugin
# Latest github pages
docker pull athackst/github:pages-dev

docker system prune -f
