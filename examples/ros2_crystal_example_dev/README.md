# ros2_crystal_example_dev

This is an example of how to create a docker development workflow

## Quickstart

Run all the steps to get the code, build the development docker and build your code.

```bash
make
```

Set up your workspace

```bash
make setup
```

Make the development docker

```bash
make docker
```

Make the workspace using the development docker

```bash
make example
```

## Set up your workspace

Create a directory to put your source code.

example:

```bash
mkdir -p ~/ros2_ws/src
```

Clone the repositories you would like to build from source

example:

```bash
cd ~/ros2_ws/src
git clone https://github.com/ros2/examples.git
```

## Build the dockerfile

Edit the docker file to include all additional resources and build the development dockerfile.  This file is special because it is built with your user id/group/name.  This allows you to build within the docker workspace as yourself.

```bash
cd ~/workstation_setup/examples/ros2_crystal_example_dev
docker build -t athackst/ros2:crystal-example-dev  --build-arg UID=$(id -u) --build-arg GID=$(id -g) --build-arg UNAME=$(whoami) .
```

## Build inside the docker image

Run the docker image with the build function

```bash
cd ~/ros2_ws
docker run -v $HOME:$HOME athackst/ros2:crystal-example-dev /build.sh `pwd`
```
