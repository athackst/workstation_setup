# This is an example of how to do a multi-stage docker
FROM athackst/ros2:crystal-dev 

WORKDIR /home/docker/ros2_ws/src
RUN git clone https://github.com/ros2/examples.git

WORKDIR /home/docker/ros2_ws
RUN /bin/bash -c "source /opt/ros/crystal/setup.bash && \
    rosdep install --from-paths src --ignore-src -y && \
    colcon build --install-base /opt/docker"

FROM athackst/ros2:crystal-base
COPY --from=0 /opt /opt

COPY example_entrypoint.sh /setup/example_entrypoint.sh

ENTRYPOINT [ "/setup/example_entrypoint.sh" ]
