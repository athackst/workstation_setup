#!/bin/bash

docker pull ubuntu:20.04
docker pull ubuntu:18.04
docker pull mcr.microsoft.com/vscode/devcontainers/base:0-focal
# kinetic images needed for deepracer
docker pull althack/ros:kinetic-base
docker pull althack/ros:kinetic-dev
# Latest ros release
docker pull althack/ros:noetic-base
docker pull althack/ros:noetic-dev
docker pull althack/ros:noetic-gazebo
# Latest ros2 release
docker pull althack/ros2:foxy-base
docker pull althack/ros2:foxy-dev
docker pull althack/ros2:foxy-gazebo
# Latest ignition release
docker pull althack/ignition:edifice-dev
# Latest mkdocs simple plugin
docker pull althack/mkdocs-simple-plugin
# Latest github pages
docker pull althack/github:pages-dev

docker system prune -f
