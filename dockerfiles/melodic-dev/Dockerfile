FROM athackst/ros:melodic-base

LABEL version="2019-12-10"

COPY install_ros_melodic_dev.sh /setup/install_ros_melodic_dev.sh
RUN /setup/install_ros_melodic_dev.sh && rm -rf /var/lib/apt/lists/*

ENTRYPOINT [ "/setup/ros_melodic_entrypoint.sh" ]
CMD ["bash"]
