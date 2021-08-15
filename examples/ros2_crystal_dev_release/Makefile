all: setup example

example: docker release.dockerfile
	docker run -it -v /home/$(shell whoami):/home/$(shell whoami) althack/ros2:crystal-example-dev /build.sh `pwd`
	docker build -f release.dockerfile -t althack/ros2:crystal-example-release .

docker: develop.dockerfile entrypoint.sh build.sh
	docker build -f develop.dockerfile -t althack/ros2:crystal-example-dev  --build-arg UID=$(shell id -u) --build-arg GID=$(shell id -g) --build-arg UNAME=$(shell whoami) .

setup: get_code.sh
	bash ./get_code.sh

uninstall:
	bash rm -fr build install log src
	docker rmi althack/ros2:crystal-example-dev
	docker system prune -f
