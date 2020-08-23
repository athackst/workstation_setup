#!/bin/bash

docker pull ubuntu:20.04
docker pull ubuntu:18.04
# kinetic images needed for deepracer 
docker pull athackst/ros:kinetic-base
docker pull athackst/ros:kinetic-dev
docker pull athackst/ros:melodic-base
docker pull athackst/ros:melodic-dev
docker pull athackst/ros:noetic-base
docker pull athackst/ros:noetic-dev
docker pull athackst/ros2:eloquent-base
docker pull athackst/ros2:eloquent-dev
docker pull athackst/ros2:foxy-base
docker pull athackst/ros2:foxy-dev
docker pull athackst/mkdocs-simple-plugin
docker pull athackst/github:pages-dev

docker system prune -f
