set-title(){
  ORIG=$PS1
  TITLE="\e]2;$@\a"
  PS1=${ORIG}${TITLE}
}

function ros2_crystal_dev() {
    docker run -it --rm --volume $HOME:$HOME --name ros2_dev athackst/ros2:crystal-dev bash
}

function create_ws() {
  git clone git@gist.github.com:db5aa13b66130f69f0b23a703b9a0424.git $1
  rm -fr $1/.git
}

function create_website() {
  curl -o gem.zip https://codeload.github.com/gist/e5e8217253f283579eb8009a17bb9b0c/zip/master 
  unzip -j gem.zip
  rm gem.zip
  bundle install --path .vendor/bundle
}

export PATH=/home/athackst/.gem/ruby/2.5.0/bin:$PATH