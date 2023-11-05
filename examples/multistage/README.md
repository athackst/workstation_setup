# multistage

This is an example of a multi-stage dockerfile to produce a target image with custom built targets.

## Quick start

### Build

```bash
make
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
docker build -f Dockerfile -t althack/ros2:crystal-example .
```
