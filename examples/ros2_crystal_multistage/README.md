# ros2_crystal_example

This is an example of a multi-stage dockerfile to produce a target image with custom built targets.

## Quickstart

### Build

```bash
make example
```

### Uninstall

```bash
make uninstall
```

## Step-by-step

### Setup your workspace

```bash
mkdir -p src
cp .rosinstall src/.rosinstall
wstool up -t src
```

### Build the dockerfile

```bash
docker build -f Dockerfile -t athackst/ros2:crystal-example .
```
