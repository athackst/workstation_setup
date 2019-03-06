
install_workstation: install_base install_docker install_vscode

install_base: scripts/install_base.sh config/.gitconfig config/.bash_aliases
	bash install_base.sh
	bash cp config/.bash_aliases ~/

install_docker: scripts/install_docker.sh
	bash install_docker.sh

install_vscode: scripts/install_vscode.sh config/Code/User/settings.json
	bash install_vscode.sh

install_ros2_crystal: scripts/install_ros2.sh scripts/install_ros2_dev.sh
	bash export ROS_DISTRO=crystal
	bash scripts/install_ros2.sh
	bash scripts/install_ros2_dev.sh

ros2_crystal: dockerfiles/ros2_crystal_base/Dockerfile dockerfiles/ros2_crystal_dev/Dockerfile 
	docker build -f dockerfiles/ros2_crystal_base/Dockerfile -t athackst/ros2:crystal-base .
	docker build -f dockerfiles/ros2_crystal_dev/Dockerfile -t athackst/ros2:crystal-dev .

push_ros2_crystal:
	docker login
	docker push athackst/ros2:crystal-base
	docker push athackst/ros2:crystal-dev

clean_dockers:
	docker rmi ros2:crystal_base
	docker rmi ros2:crystal_dev
	docker system prune -f
