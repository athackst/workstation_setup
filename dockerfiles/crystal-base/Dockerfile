FROM ubuntu:18.04

LABEL version="2019-12-23"

RUN apt-get update && apt-get install -y \
  curl \
  locales \
  sudo \
  && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.UTF-8

COPY install_ros2.sh /setup/install_ros2.sh
RUN /setup/install_ros2.sh && rm -rf /var/lib/apt/lists/*

COPY ros_crystal_entrypoint.sh /setup/ros_crystal_entrypoint.sh

ENV AMENT_PREFIX_PATH=/opt/ros/crystal
ENV COLCON_PREFIX_PATH=/opt/ros/crystal
ENV LD_LIBRARY_PATH=/opt/ros/crystal/lib
ENV PATH=/opt/ros/crystal/bin:$PATH
ENV PYTHONPATH=/opt/ros/crystal/lib/python3.6/site-packages
ENV ROS_DISTRO=crystal
ENV ROS_PYTHON_VERSION=3
ENV ROS_VERSION=2

ENTRYPOINT [ "/setup/ros_crystal_entrypoint.sh" ]
CMD ["bash"]
