# This is an example of how to do a multi-stage docker
FROM athackst/ros2:crystal-dev 

WORKDIR /home/docker/ros2_ws/src
COPY src .

COPY scripts/install_depends.sh /setup/install_depends.sh
RUN /setup/install_depends.sh && rm -rf /var/lib/apt/lists/*

WORKDIR /home/docker/ros2_ws

RUN colcon build --install-base /opt/docker

####################################
# Clean output image
###################################
FROM athackst/ros2:crystal-base

COPY scripts/install_depends.sh /setup/install_depends.sh
RUN /setup/install_depends.sh && rm -rf /var/lib/apt/lists/*

COPY --from=0 /opt/docker /opt/docker
COPY scripts/example_entrypoint.sh /setup/example_entrypoint.sh

ENTRYPOINT [ "/setup/example_entrypoint.sh" ]
