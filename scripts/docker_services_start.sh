#!/bin/bash
docker run -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock --restart=always containrrr/watchtower
docker run -d -p 5000:5000 --restart=always --name registry registry:2
