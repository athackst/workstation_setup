# workstation_setup

Scripts to capture my workstation setups

## Prerequisites

Install pre-requirements:

```bash
sudo apt install -y git make
git clone git@github.com:athackst/workstation_setup.git
```

## Install and setup workstation

Installs the basics of my workstation with make

```bash
make install
```

## Develop

I have recently been playing with the idea of doing all/most development inside of docker containers.

- [examples](examples/README.md) for example development processes

Dockerfiles have been moved to [athackst/dockerfiles](https://github.com/athackst/dockerfiles)

## Get the aliases in a container

```docker
RUN wget -O /etc/profile.d/git_aliases.sh https://github.com/athackst/workstation_setup/raw/main/user/.aliases/git_aliases.sh \
    && echo "source /etc/profile.d/git_aliases.sh" >> "/home/vscode/.bashrc"

```
