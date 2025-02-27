# workstation_setup

Scripts to capture my workstation setups

## Prerequisites

Install pre-requirements:

```bash
sudo apt install -y git python3-pip
git clone git@github.com:athackst/workstation_setup.git
```

## Set up dotfiles

Set up user [dotfiles](install.md)

```
./install.sh
```

### Get the aliases in a container

```docker
RUN wget -O /etc/profile.d/git_aliases.sh https://github.com/athackst/workstation_setup/raw/main/dotfiles/.aliases/git_aliases.sh \
    && echo "source /etc/profile.d/git_aliases.sh" >> "/home/vscode/.bashrc"
```

## Setup workstation

Installs the basics of my workstation

### Ubuntu

```bash
./setup_ubuntu.sh
```

### WSL

```bash
./setup_wsl.sh
```

## Workspaces

I have been playing with the idea of doing all/most development inside of docker containers.

- [workspaces](workspaces/README.md) for example development processes

!!! info 

    Dockerfiles have been moved to [athackst/dockerfiles](https://github.com/athackst/dockerfiles)
