# bazel

An example workspace with bazel.

## Installation

You'll need the following installed:

- [vscode](https://code.visualstudio.com/)
- [docker](https://docs.docker.com/get-docker/)
- The [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## Usage

Open this directory in VS Code from the repository root:

```bash
code workspaces/bazel
```

When prompted, reopen the folder in the development container.

### Set up your workspace

Run the `get_code.sh` script to fetch the example source.

```bash
./get_code.sh
```

This clones the Bazel examples repository into `src/examples`.

See the [Bazel C++ tutorial](https://bazel.build/start/cpp).

### Build

#### Tasks

Go to Terminal → Run Build Task or use the command palette.

!!! Note
    The checked-in task definitions currently use `${workspaceRoot}/examples/...`, while `get_code.sh` checks the tutorial out under `src/examples`. Update each task's working directory to `${workspaceFolder}/src/examples/cpp-tutorial/stageN` before using the tasks.

#### Command line

Follow the [Bazel C++ tutorial](https://bazel.build/start/cpp).

```bash
cd src/examples/cpp-tutorial/stage1
bazel build :all
```
