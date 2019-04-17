all: ros2_crystal ros_melodic

ros2_crystal:
	docker build -f ros2_crystal_base/Dockerfile -t athackst/ros2:crystal-base ros2_crystal_base/
	docker build -f ros2_crystal_dev/Dockerfile -t athackst/ros2:crystal-dev ros2_crystal_dev/

push_ros2_crystal:
	docker login
	docker push athackst/ros2:crystal-base
	docker push athackst/ros2:crystal-dev

ros_melodic:
	docker build -f ros_melodic_base/Dockerfile -t athackst/ros:melodic-base ros_melodic_base/
	docker build -f ros_melodic_dev/Dockerfile -t athackst/ros:melodic-dev ros_melodic_dev/

push_ros_melodic:
	docker login
	docker push athackst/ros:melodic-base
	docker push athackst/ros:melodic-dev

clean:
	docker rmi athackst/ros2:crystal_base
	docker rmi athackst/ros2:crystal_dev
	docker rmi athackst/ros:melodic-base
	dpcler rmi athackst/ros:melodic-dev
	docker system prune -f
