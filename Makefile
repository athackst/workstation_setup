defaults: base programs vscode docker user_config

devcontainer: base user_config

base: scripts/install_base.sh 
	bash scripts/install_base.sh

user_config: scripts/install_user_config.sh
	bash scripts/install_user_config.sh

docker: scripts/install_docker.sh
	bash scripts/install_docker.sh

jekyll: scripts/install_jekyll.sh
	bash scripts/install_jekyll.sh

programs: scripts/install_programs.sh
	bash scripts/install_programs.sh

vscode: scripts/install_vscode.sh
	bash scripts/install_vscode.sh

aws: scripts/install_aws.sh
	bash scripts/install_aws.sh

ros_noetic: export ROS_DISTRO=noetic
ros_noetic: scripts/install_ros_desktop.sh
	bash scripts/install_ros_desktop.sh

ros2_foxy: export ROS_DISTRO=foxy
ros2_foxy: scripts/install_ros2_desktop.sh
	bash scripts/install_ros2_desktop.sh
