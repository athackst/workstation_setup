FROM athackst/ros2:crystal-base 

COPY install_ros2_dev.sh /setup/install_ros2_dev.sh
RUN /setup/install_ros2_dev.sh

ENTRYPOINT [ "/setup/ros_crystal_entrypoint.sh" ]

