#!/bin/bash
set -e

sudo apt-get update && sudo apt-get install -y \
  ros-dashing-example-interfaces \
  ros-dashing-rclcpp-action
