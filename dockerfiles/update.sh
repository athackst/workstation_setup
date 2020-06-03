#!/bin/bash
set -e

push=1
TODAY=$(date +'%Y-%m-%d')

_update_docker_common() {
  
  usage() {
    echo "usage: _update_docker_common"
    echo " -r, --repository              : The remote docker repository name"
    echo " -f, --file                    : The path to the dockerfile"
    echo " -c, --context                 : The context for the docker image"
    echo " -l, --latest                  : The name of the latest tag"
    echo " -d, --dated                   : The name of the dated tag"
    echo " -h, --help                    : print this message"
  }
  
  while [ "$1" != "" ]; do
    case $1 in
      -r | --repository )
        echo "repository"
        shift
        REPOSITORY=$1
      ;;
      -f | --file )
        echo "file"
        shift
        DOCKER_FILE=$1
      ;;
      -c | --context )
        echo "context"
        shift
        CONTEXT=$1
      ;;
      -l | --latest )
        echo "latest"
        shift
        LATEST_TAG=$1
      ;;
      -d | --dated )
        echo "dated"
        shift
        DATED_TAG=$1
      ;;
      -h | --help )
        echo "help"
        usage
        return
      ;;
    esac
    shift
  done
  
  if [ -z $REPOSITORY ] || [ -z $DOCKER_FILE ] || [ -z $CONTEXT ] || [ -z $LATEST_TAG ] || [ -z $DATED_TAG ]
  then
    usage
    return 1
  fi

  docker build --pull -f $DOCKER_FILE -t $LATEST_TAG -t $REPOSITORY:$DATED_TAG --label "version=${TODAY}" $CONTEXT
  
  # Push the image to the remote.
  if [ "$push" = "1" ]; then
    docker login
    docker push $DOCKER_TAG
    docker push $DOCKER_TAG:$TODAY
  fi
  
  docker rmi $REPOSITORY:$DATED_TAG
  docker system prune -f
}

update_docker() {
  # Update the base image
  USERNAME=athackst
  DOCKER_BASE_NAME=$1
  
  REPOSITORY=$USERNAME/$DOCKER_BASE_NAME
  DOCKER_FILE=$DOCKER_BASE_NAME/Dockerfile
  CONTEXT=$DOCKER_BASE_NAME
  
  _update_docker_common --repository="${REPOSITORY}" --file="${DOCKER_FILE}" --context="${CONTEXT}" --latest="latest" --dated="${TODAY}"
}

update() {
  # Update the base image
  USERNAME=athackst
  DOCKER_BASE_NAME=$1
  DOCKER_IMG_NAME=$2
  
  REPOSITORY=$USERNAME/$DOCKER_BASE_NAME
  DOCKER_FILE=$DOCKER_BASE_NAME/$DOCKER_IMG_NAME.Dockerfile
  LATEST_TAG=$DOCKER_IMG_NAME
  DATED_TAG=$LATEST_TAG-$TODAY
  CONTEXT=$DOCKER_BASE_NAME
  
  _update_docker_common --repository="${REPOSITORY}" --file="${DOCKER_FILE}" --context="${CONTEXT}" --latest="${LATEST_TAG}" --dated="${DATED_TAG}"
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
    
    docker pull ubuntu:16.04
    update ros2 crystal-base
    update ros2 crystal-dev
  fi
}

update_gh_pages_dev() {
  update_docker gh-pages-dev
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

update_noetic() {
  update ros noetic-base
  update ros noetic-dev
}

update_all() {
  update_dashing
  update_eloquent
  update_kinetic
  update_melodic
  update_noetic
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
    noetic )
      update_noetic
    ;;
    gh-pages-dev )
      update_gh_pages_dev
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
