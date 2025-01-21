# workstation_setup

Scripts to capture my workstation setups

## Prerequisites

Install pre-requirements:

```bash
sudo apt install -y git python3-pip
git clone git@github.com:athackst/workstation_setup.git
```

## Install and setup workstation

Installs the basics of my workstation

### Ubuntu

```bash
./deploy_ubuntu.sh
```

### WSL

```bash
./deploy_wsl.sh
```

## Develop

I have been playing with the idea of doing all/most development inside of docker containers.

- [workspaces](workspaces/README.md) for example development processes

Dockerfiles have been moved to [athackst/dockerfiles](https://github.com/athackst/dockerfiles)

## Get the aliases in a container

```docker
RUN wget -O /etc/profile.d/git_aliases.sh https://github.com/athackst/workstation_setup/raw/main/dotfiles/user/.aliases/git_aliases.sh \
    && echo "source /etc/profile.d/git_aliases.sh" >> "/home/vscode/.bashrc"
```
