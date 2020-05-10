install: base programs vscode docker user_config

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

ros_melodic: export ROS_DISTRO=melodic
ros_melodic: scripts/install_ros_desktop.sh
	bash scripts/install_ros_desktop.sh

ros2_crystal: export ROS_DISTRO=crystal
ros2_crystal: scripts/install_ros2_desktop.sh
	bash scripts/install_ros2_desktop.sh

ros2_dashing: export ROS_DISTRO=dashing
ros2_dashing: scripts/install_ros2_desktop.sh
	bash scripts/install_ros2_desktop.sh

ros2_eloquent: export ROS_DISTRO=eloquent
ros2_eloquent: scripts/install_ros2_desktop.sh
	bash scripts/install_ros2_desktop.sh
