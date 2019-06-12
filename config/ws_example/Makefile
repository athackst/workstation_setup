all: setup build

setup: get_code.sh
	bash get_code.sh

build: Dockerfile
	docker build -f Dockerfile -t athackst/ros2:package-name .

uninstall:
	bash rm -fr src
	docker rmi athackst/ros2:package-name
	docker system prune -f
