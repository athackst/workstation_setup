FROM ubuntu:18.04

LABEL version="ROS2 Dashing-2019-11-23"

ENV ROS_DISTRO=dashing

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

COPY entrypoint.sh /setup/entrypoint.sh

ENV AMENT_PREFIX_PATH=/opt/ros/${ROS_DISTRO}
ENV COLCON_PREFIX_PATH=/opt/ros/${ROS_DISTRO}
ENV LD_LIBRARY_PATH=/opt/ros/${ROS_DISTRO}/lib
ENV PATH=/opt/ros/${ROS_DISTRO}/bin:$PATH
ENV PYTHONPATH=/opt/ros/${ROS_DISTRO}/lib/python3.6/site-packages
ENV ROS_PYTHON_VERSION=3
ENV ROS_VERSION=2

ENTRYPOINT [ "/setup/entrypoint.sh" ]
CMD ["bash"]
