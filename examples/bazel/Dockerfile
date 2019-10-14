FROM ubuntu:18.04

##############################
# Install dependencies
##############################
RUN apt-get update \
  && apt-get install -y \
  pkg-config \
  python3 \
  g++ \
  git \
  unzip \
  wget \
  zip \
  zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

##############################
# The version of bazel to use
##############################
ARG BAZEL_VERSION=0.28.1

RUN wget https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh \
  && chmod +x bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh \
  && ./bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh

##############################
# The version of buildifier to use
# @todo athackst Look into getting buildifier through the WORKSPACE file
# Currently, buildifier is downloaded from the release artifact and installed into
# /usr/local/bin  This seems to be the recommended way to use buildifier with vscode.
# The more "bazel" way of doing this would be to add the buildifier through bazel
# rules and build the tool with the rest of your project.
##############################
ARG BUILDIFIER_VERSION=0.28.0

RUN wget https://github.com/bazelbuild/buildtools/releases/download/${BUILDIFIER_VERSION}/buildifier \
  && chmod +x buildifier \
  && mv buildifier /usr/local/bin

# This Dockerfile adds a non-root 'vscode' user with sudo access. However, for Linux,
# this user's GID/UID must match your local user UID/GID to avoid permission issues
# with bind mounts. Update USER_UID / USER_GID if yours is not 1000. See
# https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support for the non-root user
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    # Cleanup
    && rm -rf /var/lib/apt/lists/*

RUN echo "source /usr/local/lib/bazel/bin/bazel-complete.bash" >> /home/$USERNAME/.bashrc
