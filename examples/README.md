# examples

Here are 3 examples of how to set up your docker development workflow

## 1. Multi stage docker build (ros2_crystal_multistage)

This will build and compile your code into a small output image by building your code during dockerfile creation.  

__Pros:__

* One file defines everything you need to create the image
* Repeatability built in

__Cons:__

* Takes longer to compile when a file changes (about the same as building from scratch)

## 2. Docker development environment copied into final image (ros2_crystal_dev_release)

This will build the workspace on your host machine using a docker image as the development environment.

__Pros:__

* Fastest re-build time because you can use cmake cache
* Small output image possible by passing targets into final image

__Cons:__

* Requires multiple dockerfiles to set up
* Not as repeatable (your local cache may affect build)

## 3. Docker development through VS Code (ros2_dashing_vscode)

This will use the VS Code docker container [plugin](https://code.visualstudio.com/docs/remote/containers) as the basis of development.  

Under-the-hood, vscode is running a docker container and mounting your source code into it. This gives you all the tooling you need to build your code and can enable standardization of tooling including linters.  It also seamlessly integrates with IntelliSense (which is all sorts of awesome) and enables debugging through traditional debuggers ie gdb.  

It seems to follow the develop-release pattern with docker, where a develop container is created for compiling and a then the built assets can be copied into a deployment container.  It is also possible to support multi-stage, but development would be in a docker-in-docker configuration.

__Pros:__

* All developers using the same tools (including linters, etc) in an easy to share setup
* Supported IDE functionalities such as intellisense, code following, debugging, etc.

__Cons:__

* Built targets have "root" permissions unless you've updated your base docker image to have your user name/group.
