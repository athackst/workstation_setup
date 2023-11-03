# This is an example of how to do a multi-stage docker
FROM althack/ros2:crystal-dev

WORKDIR /home/docker/ros2_ws/src
COPY src .

COPY get_depends.sh /setup/get_depends.sh
RUN /setup/get_depends.sh && rm -rf /var/lib/apt/lists/*

WORKDIR /home/docker/ros2_ws

RUN colcon build --install-base /opt/docker

###################################
# Clean output image
###################################
FROM althack/ros2:crystal-base

COPY get_depends.sh /setup/get_depends.sh
RUN /setup/get_depends.sh && rm -rf /var/lib/apt/lists/*

COPY --from=0 /opt/docker /opt/docker
COPY example_entrypoint.sh /setup/example_entrypoint.sh

ENTRYPOINT [ "/setup/example_entrypoint.sh" ]
