FROM ubuntu:16.04

LABEL version="2019-12-24"

# install packages
RUN apt-get update && apt-get install -q -y \
    dirmngr \
    gnupg2 \
    lsb-release \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# install script
ENV ROS_DISTRO="kinetic"
COPY install_ros.sh /setup/install_ros.sh
RUN /setup/install_ros.sh && rm -rf /var/lib/apt/lists/*

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

COPY ros_entrypoint.sh /setup/ros_entrypoint.sh

ENTRYPOINT [ "/setup/ros_entrypoint.sh" ]
CMD ["bash"]
