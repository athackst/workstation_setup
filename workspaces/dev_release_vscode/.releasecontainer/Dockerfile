FROM althack/ros2:dashing-base

COPY get_depends.sh /setup/get_depends.sh
RUN /setup/get_depends.sh && rm -rf /var/lib/apt/lists/*

ENV COLCON_CURRENT_PREFIX=/opt/docker
COPY install $COLCON_CURRENT_PREFIX
COPY entrypoint.sh /setup/entrypoint.sh

ENTRYPOINT [ "/setup/entrypoint.sh" ]
