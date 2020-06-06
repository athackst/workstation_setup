#!/bin/bash
set -e

push=1
TODAY=$(date +'%Y-%m-%d')

update() {
  # Update the base image
  USERNAME=athackst
  DOCKER_BASE_NAME=$1

  if [ -z $2 ]
  then
    # We haven't specified a docker name, use standard Dockerfile
    DOCKER_FILE=$DOCKER_BASE_NAME/Dockerfile
    LATEST_TAG=latest
    DATED_TAG=$TODAY
  else
    # We've specified a named dockerfile which will be used in the tag
    DOCKER_IMG_NAME=$2
    DOCKER_FILE=$DOCKER_BASE_NAME/$DOCKER_IMG_NAME.Dockerfile
    LATEST_TAG=$DOCKER_IMG_NAME
    DATED_TAG=$LATEST_TAG-$TODAY
  fi
  
  REPOSITORY=$USERNAME/$DOCKER_BASE_NAME
  CONTEXT=$DOCKER_BASE_NAME
  
  # first try to pull a remote image, if fail, 
  docker build -f $DOCKER_FILE -t $REPOSITORY:$LATEST_TAG -t $REPOSITORY:$DATED_TAG --label "version=${TODAY}" $CONTEXT
  
  # Push the image to the remote.
  if [ "$push" = "1" ]; then
    docker login
    docker push $REPOSITORY:$LATEST_TAG
    docker push $REPOSITORY:$DATED_TAG
  fi
  
  docker rmi $REPOSITORY:$DATED_TAG
  docker system prune -f
}

update_crystal() {
  read -p "WARNING: Updating EOL distribution. Are you sure? (y/n)" -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    docker pull ubuntu:16.04
    update ros2 crystal-base
    update ros2 crystal-dev
  fi
}

update_gh-pages-dev() {
  docker pull jekyll/jekyll:pages
  update gh-pages-dev
}

update_dashing() {
  docker pull ubuntu:18.04
  update ros2 dashing-base
  update ros2 dashing-dev
}

update_eloquent() {
  docker pull ubuntu:18.04
  update ros2 eloquent-base
  update ros2 eloquent-dev
}

update_foxy() {
  docker pull ubuntu:20.04
  update ros2 foxy-base
  update ros2 foxy-dev
}

update_kinetic() {
  docker pull ubuntu:18.04
  update ros kinetic-base
  update ros kinetic-dev
}

update_melodic() {
  docker pull ubuntu:18.04
  update ros melodic-base
  update ros melodic-dev
}

update_noetic() {
  docker pull ubuntu:20.04
  update ros noetic-base
  update ros noetic-dev
}

update_all() {
  # this is the list of currently active ros releases
  update_dashing
  update_eloquent
  update_foxy
  update_kinetic
  update_melodic
  update_noetic
}

usage() {
  echo "usage: update.sh [[-d] [-h]] [ release | all ]"
  echo " -d, --dry-run                 : perform a dry run of the build (ie, do not push to remote)"
  echo " -h, --help                    : print this message"
  echo " <release> | all               : Update a particular release or all currently supported releases"
}

while [ "$1" != "" ]; do
  case $1 in
    -d | --dry-run )
      push=0
    ;;
    -h | --help )
      usage
      exit
    ;;
    * )
      update_$1
  esac
  shift
done
