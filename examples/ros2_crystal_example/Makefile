all: docker

docker: Dockerfile example_entrypoint.sh
	docker build -t athackst/ros2:crystal-example

uninstall:
	docker rmi athackst/ros2:crystal-example
	docker system prune -f
