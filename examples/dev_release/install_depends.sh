#!/bin/bash
set -e

sudo apt-get update && sudo apt-get install -y \
    ros-crystal-example-interfaces \
    ros-crystal-rclcpp-action
