FROM athackst/ros:kinetic-base

LABEL version="2019-12-27"

COPY install_ros_dev.sh /setup/install_ros_dev.sh
RUN /setup/install_ros_dev.sh && rm -rf /var/lib/apt/lists/*

ENTRYPOINT [ "/setup/ros_entrypoint.sh" ]
CMD ["bash"]
