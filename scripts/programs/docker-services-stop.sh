#!/bin/bash

# md
# ## docker-services-stop
#
# Stop all my common docker services
#
# ### Usage
#
# ```sh
# docker-services-stop
# ```
#
# ### Images
#
# - registry
docker update --restart=no registry
# - notes
docker update --restart=no notes
# - watchtower
docker update --restart=no watchtower
