# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.191.0/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version: bionic, focal
ARG VARIANT="focal"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends make bash-completion python3-pip

# Source git aliases from here
RUN echo "source /workspaces/workstation_setup/user/.aliases/git_aliases.sh" >>"/home/vscode/.bashrc"
