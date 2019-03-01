FROM athackst:ros2-crystal-base

COPY scripts/install_ros2_dev.sh /setup/install_ros2_dev.sh
RUN /setup/install_ros2_dev.sh && rm -rf /var/lib/apt/lists/*

COPY scripts/ros_crystal_entrypoint.sh /setup/ros_crystal_entrypoint.sh

ENTRYPOINT [ "/setup/ros_crystal_entrypoint.sh" ]

