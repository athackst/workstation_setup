#!/bin/bash

docker update --restart=no registry
docker update --restart=no notes
docker update --restart=no watchtower
