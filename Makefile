install: install_base install_vscode install_docker install_config

install_config: scripts/install_config.sh config/.gitconfig config/.bash_aliases
	bash scripts/install_config.sh

install_base: scripts/install_base.sh 
	bash scripts/install_base.sh

install_docker: scripts/install_docker.sh
	bash scripts/install_docker.sh

install_jekyll: scripts/install_jekyll.sh
	bash scripts/install_jekyll.sh

install_vscode: scripts/install_vscode.sh
	bash scripts/install_vscode.sh

install_aws: scripts/install_aws.sh
	bash scripts/install_aws.sh

install_ros_melodic: scripts/install_ros_melodic.sh
	bash scripts/install_ros_melodic.sh

install_ros2_crystal: scripts/install_ros2.sh
	export ROS_DISTRO="crystal"
	bash scripts/install_ros2.sh

install_ros2_dashing: scripts/install_ros2.sh
	export ROS_DISTRO="dashing"
	bash scripts/install_ros2.sh

install_ros2_eloquent: scripts/install_ros2.sh
	export ROS_DISTRO="eloquent"
	bash scripts/install_ros2.sh
