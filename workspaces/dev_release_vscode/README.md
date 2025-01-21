# dev_release_vscode

This is an example using ros2 dashing + vscode + docker.

## Quick start

1. Open this folder in vscode and load the container.
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

Run the script get_code to download the example code.

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
> id -u #user id
> ig -g #group id
> ```

### Open the folder in a remote container

Open the command pallet and select the `Remote-Containers: Open Folder in Container` option.

VSCode will build the docker file and mount the folder into the container.

From here, you can build the source by running the `build` task.

```text
Terminal->Run Build task
```

This will run

```bash
colcon build
```

in the current working directory.

## Deployment

The deployment steps for this workflow are similar [dev_release](../dev_release/README.md) release workflow.  Development is performed in a different container than the release, where the build outputs are copied into the release container.

Run the release script on the host computer.

```bash
./release.sh
```

This will build the release container by copying the built targets into the host into the /opt/docker folder.

```bash
docker build -f ./.releasecontainer/Dockerfile -t vscode/ros2:ros2_dashing_vscode .
```

You may want to change the tag name to fit your project.
