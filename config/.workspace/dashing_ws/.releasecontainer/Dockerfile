FROM athackst/ros2:dashing-base

COPY install_depends.sh /setup/install_depends.sh
RUN /setup/install_depends.sh && rm -rf /var/lib/apt/lists/*

ENV COLCON_CURRENT_PREFIX=/opt/docker
COPY install $COLCON_CURRENT_PREFIX
COPY entrypoint.sh /setup/entrypoint.sh

ENTRYPOINT [ "/setup/entrypoint.sh" ]
