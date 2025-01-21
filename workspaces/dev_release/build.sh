cd $1
su ${USER} -c 'colcon build --merge-install $@'
