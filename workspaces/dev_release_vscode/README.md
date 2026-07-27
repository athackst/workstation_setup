# dev_release_vscode

This is an example using ROS 2 Dashing, VS Code, and Docker.

## Quick start

1. Open this folder in VS Code and choose **Dev Containers: Reopen in Container**.
2. Download the example package

    ```bash
    ./get_code.sh
    ```

3. Build the code in the attached terminal.

    ```bash
    colcon build
    ```

## Detailed instructions

### Get the example code

Run `get_code.sh` to download the example code.

```bash
./get_code.sh
```

This will download the ROS packages listed in the `.rosinstall` file.

> Note: you can also run
>
> ```bash
> mkdir -p src
> vcs import < .rosinstall src
> ```
>
> to get the sources listed in the .rosinstall package.

### Update the dockerfile for your user/group

If you're user id/group is different than the default 1000/1000 for linux, you will need to edit the container with your user id/group.

> Note: To find your user id/group:
>
>```bash
> id -u # user ID
> id -g # group ID
> ```

### Open the folder in a remote container

Open the command palette and select **Dev Containers: Reopen in Container**. If the folder is not already open in a container, use **Dev Containers: Open Folder in Container** instead.

VSCode will build the docker file and mount the folder into the container.

From here, you can build the source by running the `build` task.

```text
Terminal->Run Build task
```

The default build task runs in the current working directory:

```bash
colcon build --cmake-args '-DCMAKE_BUILD_TYPE=Release'
```

The workspace also provides debug and test tasks for `colcon build --cmake-args '-DCMAKE_BUILD_TYPE=Debug'` and `colcon test && colcon test-result`.

## Deployment

The deployment steps for this workflow are similar to the [dev_release](../dev_release/README.md) release workflow. Development is performed in a different container from the release container; the built `install` directory is copied into the release image at `/opt/docker`.

After a successful build, run the release script from this directory on the host:

```bash
./release.sh
```

This builds the release container using the local `install` directory.

```bash
docker build -f ./.releasecontainer/Dockerfile -t vscode/ros2:ros2_dashing_vscode .
```

You may want to change the tag name to fit your project.
