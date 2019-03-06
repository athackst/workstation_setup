all: docker example

example: docker
	docker run -it -v /home/$(shell whoami):/home/$(shell whoami) athackst/ros2:crystal-example-dev /build.sh /home/$(shell whoami)/ros2_ws

docker: Dockerfile entrypoint.sh build.sh
	docker build -t athackst/ros2:crystal-example-dev  --build-arg UID=$(shell id -u) --build-arg GID=$(shell id -g) --build-arg UNAME=$(shell whoami) .

uninstall:
	docker rmi athackst/ros2:crystal-example-dev
	docker system prune -f
