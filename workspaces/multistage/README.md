# multistage

This is an example of a multi-stage Dockerfile that produces a runtime image with custom-built targets.

## Quick start

### Build

```bash
make
```

### Clean up

```bash
rm -rf src
docker rmi althack/ros2:crystal-example
```

## Step-by-step

### Set up your workspace

Run the setup script directly, or let `make` invoke it as part of the build:

```bash
./get_code.sh
```

The equivalent manual commands are:

```bash
mkdir -p src
cp .rosinstall src/.rosinstall
wstool up -t src
```

### Build the dockerfile

```bash
docker build -f Dockerfile -t althack/ros2:crystal-example .
```
