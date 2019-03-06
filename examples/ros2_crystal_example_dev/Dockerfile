# This is an example of an interactive development environment
FROM athackst/ros2:crystal-dev

# install any extra required packages
RUN apt-get update && apt-get install -y \
    ros-crystal-example-interfaces \ 
    ros-crystal-rclcpp-action \
    && rm -rf /var/lib/apt/lists/*

# add your user parameters
ARG UNAME=docker
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $U bvNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME
RUN usermod -aG sudo $UNAME
RUN passwd -d $UNAME

COPY build.sh /build.sh
COPY entrypoint.sh /setup/entrypoint.sh

WORKDIR /home/$UNAME
ENV USER=$UNAME

ENTRYPOINT [ "/setup/entrypoint.sh" ]
# CMD ["$@"]
