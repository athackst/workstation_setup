FROM athackst/ros:melodic-base

LABEL version="2020-05-04"

COPY install_ros_dev.sh /setup/install_ros_dev.sh
RUN /setup/install_ros_dev.sh && rm -rf /var/lib/apt/lists/*

CMD ["bash"]
