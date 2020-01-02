FROM ubuntu:18.04

LABEL version="2019-12-31"

# setup timezone
RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && apt-get install -q -y tzdata && rm -rf /var/lib/apt/lists/*

# install packages
RUN apt-get update && apt-get install -q -y \
    dirmngr \
    gnupg2 \
    lsb-release \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# install script
ENV ROS_DISTRO="melodic"
COPY install_ros.sh /setup/install_ros.sh
RUN /setup/install_ros.sh && rm -rf /var/lib/apt/lists/*

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
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
