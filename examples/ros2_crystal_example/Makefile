all: example

example: Dockerfile scripts/get_code.sh 
	bash scripts/get_code.sh
	docker build -f Dockerfile -t athackst/ros2:crystal-example .

uninstall:
	bash rm -fr src
	docker rmi athackst/ros2:crystal-example
	docker system prune -f
