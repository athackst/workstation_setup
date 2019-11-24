FROM jekyll/jekyll:pages

COPY Gemfile* /srv/jekyll/

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
	sudo

RUN	bundle install && bundle update

ENV USERNAME=jekyll
RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME

EXPOSE 4000

CMD bundle exec jekyll serve
