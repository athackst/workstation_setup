#!/bin/bash

docker run -d -p 5000:5000 --restart=always --name registry registry:2
docker run -d -p 8123:8000 --restart=always --name notes -v ~/Notes:/docs -e THEME=material -e SITE_DIR="/test" althack/mkdocs-simple-plugin:latest
