all: build

build: Dockerfile get_code.sh 
	bash get_code.sh
	docker build -f Dockerfile -t althack/ros2:crystal-example .

uninstall:
	bash rm -fr src
	docker rmi althack/ros2:crystal-example
	docker system prune -f
