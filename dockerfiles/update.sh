#!/bin/bash
set -e

push=1

update() {
  # Update the base image
  docker pull ubuntu:18.04
  docker pull ubuntu:16.04
  USERNAME=athackst
  DOCKER_BASE_NAME=$1
  DOCKER_IMG_NAME=$2
  DOCKER_FILE=$DOCKER_BASE_NAME/$DOCKER_IMG_NAME.Dockerfile
  CONTEXT=$DOCKER_BASE_NAME
  DOCKER_TAG=$USERNAME/$DOCKER_BASE_NAME:$DOCKER_IMG_NAME
  
  # Modify the label to todays date.
  TODAY=$(date +'%Y-%m-%d')
  sed -i "/LABEL/c\LABEL version=\"${TODAY}\"" $DOCKER_FILE
  
  # Build the image.
  docker build -f $DOCKER_FILE -t $DOCKER_TAG $CONTEXT
  docker tag $DOCKER_TAG $DOCKER_TAG-$TODAY
  
  # Push the image to the remote.
  if [ "$push" = "1" ]; then
    docker login
    docker push $DOCKER_TAG
    docker push $DOCKER_TAG-$TODAY
  fi
  
  docker rmi $DOCKER_TAG-$TODAY
  docker system prune -f
}

usage() {
  echo "usage: update.sh [[-d] [-h]] | [[dashing] [eloquent] [kinetic] [melodic] [all]]"
  echo " -d, --dry-run                 : perform a dry run of the build (ie, do not push to remote)"
  echo " -h, --help                    : print this message"
  echo " [[dashing] [eloquent] [kinetic] [melodic] [all]] : release name"
}

update_crystal() {
  read -p "WARNING: Updating EOL distribution. Are you sure? (y/n)" -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    update ros2 crystal-base
    update ros2 crystal-dev
  fi
}

update_dashing() {
  update ros2 dashing-base
  update ros2 dashing-dev
}

update_eloquent() {
  update ros2 eloquent-base
  update ros2 eloquent-dev
}

update_kinetic() {
  update ros kinetic-base
  update ros kinetic-dev
}

update_melodic() {
  update ros melodic-base
  update ros melodic-dev
}

update_all() {
  update_dashing
  update_eloquent
  update_kinetic
  update_melodic
}

while [ "$1" != "" ]; do
  case $1 in
    crystal )
      update_crystal
    ;;
    dashing )
      update_dashing
    ;;
    eloquent )
      update_eloquent
    ;;
    kinetic )
      update_kinetic
    ;;
    melodic )
      update_melodic
    ;;
    all )
      update_all
    ;;
    -d | --dry-run )
      push=0
    ;;
    -h | --help )
      usage
      exit
    ;;
    * )
      usage
      exit
  esac
  shift
done
