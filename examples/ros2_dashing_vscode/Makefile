all: setup build

setup: get_code.sh
	bash get_code.sh

build: Dockerfile
	docker build -f Dockerfile -t athackst/ros2:ws .

uninstall:
	bash rm -fr src
	docker rmi athackst/ros2:ws
	docker system prune -f
