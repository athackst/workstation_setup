FROM jekyll/jekyll:pages

COPY Gemfile /srv/jekyll/

WORKDIR /srv/jekyll

RUN apk update && apk add \
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
	openssh \
	sudo \
	git-bash-completion

RUN	bundle install && bundle update

# Set up user so that we can share ssh credentials.
ENV USERNAME=jekyll
RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set up git completion.
RUN echo "source /usr/share/bash-completion/completions/git" >> /home/$USERNAME/.bashrc

EXPOSE 4000

CMD bundle exec jekyll serve
