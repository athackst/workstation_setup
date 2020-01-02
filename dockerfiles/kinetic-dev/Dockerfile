FROM athackst/ros:kinetic-base

LABEL version="2019-12-31"

COPY install_ros_dev.sh /setup/install_ros_dev.sh
RUN /setup/install_ros_dev.sh && rm -rf /var/lib/apt/lists/*

CMD ["bash"]
