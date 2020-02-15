FROM athackst/ros2:dashing-base 

LABEL version="2020-02-15"

COPY install_ros2_dev.sh /setup/install_ros2_dev.sh
RUN /setup/install_ros2_dev.sh

ENTRYPOINT [ "/setup/entrypoint.sh" ]
CMD ["bash"]
