# examples

Here are 2 examples of how to set up your docker development workflow

## 1. Multi stage docker build (ros2_crystal_example)

This will build and compile your code into a small output image by building your code during dockerfile creation.  

__Pros:__

* One file defines everything you need to create the image
* Repeatability built in

__Cons:__

* Takes longer to compile when a file changes (about the same as building from scratch)

## 2. Docker development environment copied into final image (ros2_crystal_exaple_dev)

This will build the workspace on your host machine using a docker image as the development environment.

__Pros:__

* Fastest re-build time because you can use cmake cache
* Small output image possible by passing targets into final image

__Cons:__

* Requires multiple dockerfiles to set up
* Not as repeatable (your local cache may affect build)
