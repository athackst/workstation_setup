FROM jekyll/jekyll:pages

LABEL version="2020-05-23"

RUN apk update && apk add \
    # development packages
    ruby-dev \
    gcc \
    make \
    curl \
    build-base \
    libc-dev \
    libffi-dev \
    zlib-dev \
    libxml2-dev \
    libgcrypt-dev \
    libxslt-dev \
    python \
    # pushing to git via ssh
    openssh \
    # permissions to install packages
    sudo \
    # tab completion inside the container
    git-bash-completion \
    && rm -rf /var/lib/apt/lists/*

# Set up development user.
ARG USERNAME=jekyll
RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  && echo "source /usr/share/bash-completion/completions/git" >> /home/$USERNAME/.bashrc

EXPOSE 4000

CMD ["bundle", "exec", "jekyll", "serve"]
