FROM ubuntu:18.04

LABEL version="2019-12-21"

# setup timezone
RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && apt-get install -q -y tzdata && rm -rf /var/lib/apt/lists/*

# install packages
RUN apt-get update && apt-get install -q -y \
    dirmngr \
    gnupg2 \
    lsb-release \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# install script
COPY install_ros_melodic.sh /setup/install_ros_melodic.sh
RUN /setup/install_ros_melodic.sh && rm -rf /var/lib/apt/lists/*

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

COPY ros_melodic_entrypoint.sh /setup/ros_melodic_entrypoint.sh

ENTRYPOINT [ "/setup/ros_melodic_entrypoint.sh" ]
CMD ["bash"]
