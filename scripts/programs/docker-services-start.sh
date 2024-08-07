#!/bin/bash

# md
# ## docker-services-start
#
# Starts all my common docker services
#
# ### Usage
#
# ```sh
# docker-services-start
# ```
#
# ### Dockers
#
# - registry
docker run -d -p 5000:5000 --restart=always --name registry registry:2
# - notes mkdocs server
docker run -d -p 8123:8000 --restart=always --name notes -v ~/Notes:/docs -e THEME=material -e SITE_DIR="/test" althack/mkdocs-simple-plugin:latest
# - watchtower
docker run -d --restart=always --name watchtower --volume /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --include-restarting --cleanup
