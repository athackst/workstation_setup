FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
  curl \
  locales \
  sudo \
  && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.UTF-8

# # setup timezone
# RUN echo 'Etc/UTC' > /etc/timezone && \
#   ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
#   apt-get update && apt-get install -q -y tzdata && rm -rf /var/lib/apt/lists/*

COPY scripts/install_ros2.sh /setup/install_ros2.sh
RUN /setup/install_ros2.sh && rm -rf /var/lib/apt/lists/*

COPY scripts/ros_crystal_entrypoint.sh /setup/ros_crystal_entrypoint.sh

ENTRYPOINT [ "/setup/ros_crystal_entrypoint.sh" ]
CMD [ 'bash' ]
