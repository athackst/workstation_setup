#!/bin/bash

# md
# ## docker-images-update
#
# Pulls the latest docker images for my most-used images
#
# ### Usage
#
# ```sh
# docker-images-update
# ```
#
docker system prune -f
#
# ### Images
#
# This pulls the latest images for:
#
docker pull ubuntu:22.04
docker pull mcr.microsoft.com/devcontainers/base:jammy
# - kinetic images needed for deepracer
docker pull althack/ros:kinetic-base
docker pull althack/ros:kinetic-dev
# - Latest ros release (noetic)
docker pull althack/ros:noetic-base
docker pull althack/ros:noetic-dev
docker pull althack/ros:noetic-gazebo
# - Latest ros2 release (humble)
docker pull althack/ros2:humble-base
docker pull althack/ros2:humble-dev
docker pull althack/ros2:humble-gazebo
# - Latest ignition release (harmonic)
docker pull althack/gz:harmonic-dev
# - Latest mkdocs simple plugin
docker pull althack/mkdocs-simple-plugin
# - Latest github pages
docker pull althack/github:pages-dev
# /md
