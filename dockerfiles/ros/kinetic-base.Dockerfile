FROM ubuntu:16.04

LABEL version="2020-05-04"

ENV ROS_DISTRO="kinetic"

# Install language
RUN apt-get update && apt-get install -y \
  locales \
  && locale-gen en_US.UTF-8 \
  && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
  && rm -rf /var/lib/apt/lists/*
ENV LANG en_US.UTF-8

# Install timezone
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y tzdata \
  && dpkg-reconfigure --frontend noninteractive tzdata \
  && rm -rf /var/lib/apt/lists/*

# install ROS
COPY install_ros_base.sh /setup/install_ros_base.sh
RUN /setup/install_ros_base.sh && rm -rf /var/lib/apt/lists/*

# setup environment
ENV LD_LIBRARY_PATH=/opt/ros/$ROS_DISTRO/lib:$LD_LIBRARY_PATH
ENV ROS_ROOT=/opt/ros/$ROS_DISTRO/share/ros
ENV ROS_PACKAGE_PATH=/opt/ros/$ROS_DISTRO/share
ENV ROS_MASTER_URI=http://localhost:11311
ENV ROS_PYTHON_VERSION=2
ENV ROS_VERSION=1
ENV PATH=/opt/ros/$ROS_DISTRO/bin:$PATH
ENV ROSLISP_PACKAGE_DIRECTORIES=
ENV PYTHONPATH=/opt/ros/$ROS_DISTRO/lib/python2.7/dist-packages:$PYTHONPATH
ENV PKG_CONFIG_PATH=/opt/ros/$ROS_DISTRO/lib/pkgconfig:$PKG_CONFIG_PATH
ENV ROS_ETC_DIR=/opt/ros/$ROS_DISTRO/etc/ros
ENV CMAKE_PREFIX_PATH=/opt/ros/$ROS_DISTRO:$CMAKE_PREFIX_PATH

CMD ["bash"]
