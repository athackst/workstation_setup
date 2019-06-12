FROM athackst/ros2:dashing-base 

COPY install_ros2_dev.sh /setup/install_ros2_dev.sh
RUN /setup/install_ros2_dev.sh

ENTRYPOINT [ "/setup/entrypoint.sh" ]
CMD ["bash"]
