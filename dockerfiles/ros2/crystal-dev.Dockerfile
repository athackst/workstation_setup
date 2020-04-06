FROM athackst/ros2:crystal-base

LABEL version="2019-12-23"

COPY install_ros2_dev.sh /setup/install_ros2_dev.sh
RUN /setup/install_ros2_dev.sh

CMD ["bash"]
