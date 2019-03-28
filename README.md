# workstation_setup

Scripts to capture how to set up my workstation

## Usage

Install prereqs:

```
sudo apt install -y git make
git clone git@github.com:athackst/workstation_setup.git

```

### Install and setup workstation

This installs the basics of my workstation including:

```bash
make install_workstation
```

### Build crystal docker images

This builds basic and development environments for ros2 without extra dependencies.

```bash
make docker_ros2_crystal
```

Use them as a reference to create the development and base docker files for docker-based ros development

## FAQ

__Q: Why build code inside a docker?__

> Recreatable building environment that can be duplicated in Continuous Integration or sent to others to duplicate issues.
