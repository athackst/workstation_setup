set-title(){
  ORIG=$PS1
  TITLE="\e]2;$@\a"
  PS1=${ORIG}${TITLE}
}

function create_ws() {
  if [ $# -eq 0 ]
    then
      echo "Usage: create_ws <name>"
      exit 1
  fi
  cp -r $HOME/.ros/ws_example $1
}

function create_website() {
  curl -o gem.zip https://codeload.github.com/gist/e5e8217253f283579eb8009a17bb9b0c/zip/master 
  unzip -j gem.zip
  rm gem.zip
  bundle install --path .vendor/bundle
}

export PATH=/home/athackst/.gem/ruby/2.5.0/bin:$PATH