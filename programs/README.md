# Programs

These are scripts that can be run as an executable once installed.

It's a convenient way to add scripts to the program list.  The program list allows for tab completion in the terminal.

## Installation

To install just run pip install

```bash
pip install .
```

## Usage

### docker-decendents

Get all of the decendent images of a docker image

### docker-services-start

Start all of my core docker servies like registry, notes, and watchtower

### docker-services-stop

Stop all of my docker services to keep them from restarting

### docker-services-update

Run the watchtower update once on command.

### gif-gen

Generates a gif from a video, including automatic "good" compression

```bash
gif-gen -h
```

### update-docker-images

Updates (pulls) the docker images I want to have on my system.

### user-config-diff

Diffs my configuration with the one in this package[^1].

### user-config-update

Update the user config in this package with my system config[^1].

[^1]: Location of this project must be in ~/Code
