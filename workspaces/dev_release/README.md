# dev_release

This is an example of how to create a docker development workflow

## Quick start

From this directory, run all the steps to get the code, build the development image, build the code, and build the release image.

```bash
cd /path/to/workstation_setup/workspaces/dev_release
make
```

### Set up

Set up your workspace

```bash
make setup
```

### Build

Make the development environment docker

```bash
make docker
```

### Install

Make the workspace using the development docker

```bash
make example
```

## Step-by-step

### Set up your workspace

The workspace uses the ROS 2 Crystal example listed in `.rosinstall`. Create the source directory and fetch it with the setup target:

```bash
make setup
```

To use different repositories, edit `.rosinstall` before running `make setup`.

```bash
cat src/.rosinstall
```

### Build the dockerfile

Edit `develop.dockerfile` to include any additional resources, then build the development image. It is built with your user ID, group ID, and name so builds run as your host user.

```bash
docker build -f develop.dockerfile -t althack/ros2:crystal-example-dev \
  --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" \
  --build-arg UNAME="$(whoami)" .
```

### Build inside the docker image

Run the docker image with the build function

```bash
docker run -it -v "/home/$(whoami):/home/$(whoami)" \
  althack/ros2:crystal-example-dev /build.sh "$(pwd)"
```

### Copy install targets into release docker image

Build the release docker image that will copy the install targets into the image

```bash
docker build -f release.dockerfile -t althack/ros2:crystal-example-release .
```
