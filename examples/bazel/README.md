# bazel

An example workspace with bazel.

## Installation

You'll need the following packages installed:

- [vscode](https://code.visualstudio.com/)
- [docker](https://docs.docker.com/get-docker/)

## Usage

Open this directory in vscode 

```bash
code workstation_setup/examples/bazel
```

### Set up your workspace

Run the get_code script, then open this folder in vscode.

```bash
./get_code.sh
```

This will download the bazel example code repository.

See [bazel tutorials](https://docs.bazel.build/versions/master/tutorial/cpp.html)

### Build

#### Tasks

Go to Terminal->Run Build Task or type the shortcut command.

!!! Note
    The working directory for a running task needs to be set to the directory containing a `WORKSPACE` file.

    You can use vscode environment variables to set the worksapce

    ```json
        {
            "label": "build stage1",
            "type": "shell",
            "options": {
                "cwd": "${workspaceRoot}/examples/cpp-tutorial/stage1"
            },
            "command": "bazel build //main:hello-world",
            "problemMatcher": [
                "$gcc"
            ],
            "group": "build"
        },
    ```

#### Command line

Follow the instructions in the  [bazel tutorials](https://docs.bazel.build/versions/master/tutorial/cpp.html)

```bash
cd examples/cpp-tutorial/stage1
bazel build :all
```
