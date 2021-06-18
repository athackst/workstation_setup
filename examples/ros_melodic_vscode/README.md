# ros_melodic_vscode

This is an example/test workspace for ros melodic.

## About

This workspace is set up to test using a ros melodic dev container using the beginners tutorials from ROS.

## Installation

You'll need the following packages installed:

- [vscode](https://code.visualstudio.com/)
- [docker](https://docs.docker.com/get-docker/)

## Usage

Open this directory in vscode

```bash
code workstation_setup/examples/ros_melodic_vscode
```

It will ask you if you'd like to open using a container.  Hit yes!

### Set up your workspace

The first thing you're going to want to do is set up your workspace.

```bash
wstool up
```

This will download the beginner tutorial code into your workspace.

See [ros beginner tutorials](https://wiki.ros.org/ROS/Tutorials/WritingPublisherSubscriber%28c%2B%2B%29).

### Build

#### Tasks

Go to Terminal->Run Build Task or type the shortcut command.

#### Command line

Alternatively, you can build from the command line.

```bash
catkin build
```

### Run

In order to run the tutorials, first you'll need to source your workspace.

```bash
source devel/setup.bash
```

Then run the tutorial you're interested in, for example

```bash
roslaunch roscpp_tutorials talker_listener.launch
```
