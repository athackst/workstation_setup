# This is the development environment
FROM athackst/ros2:dashing-dev 

COPY install_depends.sh /setup/install_depends.sh
RUN /setup/install_depends.sh && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /setup/entrypoint.sh

ENTRYPOINT [ "/setup/entrypoint.sh" ]
