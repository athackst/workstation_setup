FROM athackst/ros2:eloquent-base 

LABEL version="2020-05-04"

COPY install_ros2_dev.sh /setup/install_ros2_dev.sh
RUN /setup/install_ros2_dev.sh

CMD ["bash"]
