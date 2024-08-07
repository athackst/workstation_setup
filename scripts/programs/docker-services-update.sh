#!/bin/bash

# md
# ## docker-services-update
#
# Use watchtower to update running docker containers
#
# ### Usage
#
# ```sh
# docker-services-update
# ```
# /md

docker run --rm -t --name watchtower-update --volume /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --include-restarting --cleanup --run-once
