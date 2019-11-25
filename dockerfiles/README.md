# dockerfiles

These are base docker images for developing code.

You can use them as a base image for development with VSCode using container based development.

## Quick start

Build the current LTS ROS docker images.

```bash
make all
```

### Update your built docker image on dockerhub

Run the update script to update the docker image and push it to docker hub.

```bash
./update.sh
```

You will be prompted for the name of the remote and the name of the image.

## Build the docker images

### ros melodic

```bash
make ros_melodic
```

### ros2 crystal

```bash
make ros2_crystal
```

### ros2 dashing

```bash
make ros2_dashing
```

### ros2 eloquent

```bash
make ros2_eloquent
```

## FAQ

__Q: Why build code inside a docker?__

> Re-creatable building environment that can be duplicated in Continuous Integration or sent to others to duplicate issues.

__Q: What is needed to set up vscode to work with docker as a development container?__

> You need to create a non-root user with the same user id and group as your user, and you need to mount your .ssh configuration inside the container.
