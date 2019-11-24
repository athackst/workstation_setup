#!/bin/bash

set -e

# Get image information from user.
read -p "Docker base name? (athackst/ros2): " DOCKER_BASE_NAME
if [ -z $DOCKER_BASE_NAME ]
then
    DOCKER_BASE_NAME="athackst/ros2"
fi
echo "DOCKER_BASE_NAME: ${DOCKER_BASE_NAME}"

read -p "Docker image name? (dashing-base): " DOCKER_IMG_NAME
if [ -z $DOCKER_IMG_NAME ]
then
    DOCKER_BASE_NAME="dashing-base"
fi
echo "DOCKER_IMG_NAME: ${DOCKER_IMG_NAME}"

# Modify the label to todays date.
TODAY=$(date +'%Y-%m-%d')
sed -i "/LABEL/c\LABEL version=\"${TODAY}\"" $DOCKER_IMG_NAME/Dockerfile

# Build the image.
docker build -f $DOCKER_IMG_NAME/Dockerfile -t $DOCKER_BASE_NAME:$DOCKER_IMG_NAME $DOCKER_IMG_NAME/
docker tag $DOCKER_BASE_NAME:$DOCKER_IMG_NAME $DOCKER_BASE_NAME:$DOCKER_IMG_NAME-$TODAY

# Push the image to the remote.
docker login
docker push $DOCKER_BASE_NAME:$DOCKER_IMG_NAME
docker push $DOCKER_BASE_NAME:$DOCKER_IMG_NAME-$TODAY