all: setup example

example: docker
	docker run -it -v /home/$(shell whoami):/home/$(shell whoami) athackst/ros2:crystal-example-dev /build.sh `pwd`
	docker build -f release.dockerfile -t athackst/ros2:crystal-example-release .

docker: develop.dockerfile entrypoint.sh build.sh
	docker build -f develop.dockerfile -t athackst/ros2:crystal-example-dev  --build-arg UID=$(shell id -u) --build-arg GID=$(shell id -g) --build-arg UNAME=$(shell whoami) .

setup: get_code.sh
	bash ./get_code.sh

uninstall:
	docker rmi athackst/ros2:crystal-example-dev
	docker system prune -f
