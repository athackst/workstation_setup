install: install_base install_docker install_vscode

install_base: scripts/install_base.sh config/.gitconfig config/.bash_aliases
	bash scripts/install_base.sh

install_docker: scripts/install_docker.sh
	bash scripts/install_docker.sh

install_vscode: scripts/install_vscode.sh
	bash scripts/install_vscode.sh

install_ros2_crystal: scripts/install_ros2_crystal.sh
	bash scripts/install_ros2_crystal.sh
