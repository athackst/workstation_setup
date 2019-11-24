all: ros2_dashing ros_melodic

ros_melodic:
	docker build -f melodic-base/Dockerfile -t athackst/ros:melodic-base melodic-base/
	docker build -f melodic-dev/Dockerfile -t athackst/ros:melodic-dev melodic-dev/

ros2_crystal:
	docker build -f crystal-base/Dockerfile -t athackst/ros2:crystal-base crystal-base/
	docker build -f crystal-dev/Dockerfile -t athackst/ros2:crystal-dev crystal-dev/

ros2_dashing:
	docker build -f dashing-base/Dockerfile -t athackst/ros2:dashing-base dashing-base/
	docker build -f dashing-dev/Dockerfile -t athackst/ros2:dashing-dev dashing-dev/

ros2_eloquent:
	docker build -f eloquent-base/Dockerfile -t athackst/ros2:eloquent-base eloquent-base/
	docker build -f eloquent-dev/Dockerfile -t athackst/ros2:eloquent-dev eloquent-dev/

clean:
	docker rmi athackst/ros:melodic-base
	dpcler rmi athackst/ros:melodic-dev
	docker rmi athackst/ros2:crystal-base
	docker rmi athackst/ros2:crystal-dev
	docker rmi athackst/ros2:dashing-base
	docker rmi athackst/ros2:dashing-dev
	docker rmi athackst/ros2:eloquent-base
	docker rmi athackst/ros2:eloquent-dev
	docker system prune -f
