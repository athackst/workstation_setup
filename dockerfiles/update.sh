#!/bin/bash

set -e

push=1

update() {
    # Update the base image
    docker pull ubuntu:18.04
    DOCKER_BASE_NAME=$1
    DOCKER_IMG_NAME=$2
    
    # Modify the label to todays date.
    TODAY=$(date +'%Y-%m-%d')
    sed -i "/LABEL/c\LABEL version=\"${TODAY}\"" $DOCKER_IMG_NAME/Dockerfile
    
    # Build the image.
    docker build -f $DOCKER_IMG_NAME/Dockerfile -t $DOCKER_BASE_NAME:$DOCKER_IMG_NAME $DOCKER_IMG_NAME/
    docker tag $DOCKER_BASE_NAME:$DOCKER_IMG_NAME $DOCKER_BASE_NAME:$DOCKER_IMG_NAME-$TODAY
    
    # Push the image to the remote.
    if [ "$push" = "1" ]; then
        docker login
        docker push $DOCKER_BASE_NAME:$DOCKER_IMG_NAME
        docker push $DOCKER_BASE_NAME:$DOCKER_IMG_NAME-$TODAY
    fi
    
    docker rmi $DOCKER_BASE_NAME:$DOCKER_IMG_NAME-$TODAY
    docker system prune -f
}

usage() {
    echo "usage: update.sh [[[-b docker_base_name ] [-i docker_image_name]] | [-a] [-d] [-h]]"
    echo " -b, --base docker_base_name   : docker image base name"
    echo " -i, --image docker_image_name : docker image tag"
    echo " -a, --all                     : update all currently supported images"
    echo " -d, --dry-run                 : perform a dry run of the build (ie, do not push to remote)"
    echo " -h, --help                    : print this message"
}

update_all() {
    update athackst/ros2 dashing-base
    update athackst/ros2 dashing-dev
    update athackst/ros2 eloquent-base
    update athackst/ros2 eloquent-dev
    update athackst/ros melodic-base
    update athackst/ros melodic-dev
}

interactive=

while [ "$1" != "" ]; do
    case $1 in
        -b | --base )
            shift
            DOCKER_BASE_NAME=$1
        ;;
        -i | --image )
            shift
            DOCKER_IMG_NAME=$1
        ;;
        -d | --dry-run )
            push=0
        ;;
        -a | --all )
            update_all
            exit
        ;;
        -h | --help )
            usage
            exit
        ;;
        * )
            usage
            exit
        ;;
    esac
    shift
done

if [ -z $DOCKER_BASE_NAME ] || [ -z $DOCKER_IMG_NAME ]; then
    interactive=1
fi

if [ "$interactive" = "1" ]; then
    read -p "Docker base name? " DOCKER_BASE_NAME
    if [ -z $DOCKER_BASE_NAME ]
    then
        echo "Must provide docker base name"
        exit
    fi
    read -p "Docker image name? " DOCKER_IMG_NAME
    if [ -z $DOCKER_IMG_NAME ]
    then
        echo "Must provide docker image name"
        exit
    fi
fi
echo "DOCKER_BASE_NAME: ${DOCKER_BASE_NAME}"
echo "DOCKER_IMG_NAME: ${DOCKER_IMG_NAME}"

update $DOCKER_BASE_NAME $DOCKER_IMG_NAME