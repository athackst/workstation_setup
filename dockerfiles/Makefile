all: ros2_crystal

ros2_crystal:
	docker build -f ros2_crystal_base/Dockerfile -t athackst/ros2:crystal-base ros2_crystal_base/
	docker build -f ros2_crystal_dev/Dockerfile -t athackst/ros2:crystal-dev ros2_crystal_dev/

push_ros2_crystal:
	docker login
	docker push athackst/ros2:crystal-base
	docker push athackst/ros2:crystal-dev

clean:
	docker rmi ros2:crystal_base
	docker rmi ros2:crystal_dev
	docker system prune -f
