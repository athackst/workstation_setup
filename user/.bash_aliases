title(){
  ORIG=$PS1
  TITLE="\e]2;$@\a"
  PS1=${ORIG}${TITLE}
}
########################
# bazel shortcus
########################
if [ -f ~/.bash_aliases_bazel ]; then
  . ~/.bash_aliases_bazel
  
  
  alias bb="bazel build"
  _my_bb_alias_autocomplete() {
    _bazel__complete_target_stdout "build"
  }
  complete -o nospace -F _my_bb_alias_autocomplete bb
  
  alias bt="bazel test"
  _my_bt_alias_autocomplete() {
    _bazel__complete_target_stdout "test"
  }
  complete -o nospace -F _my_bt_alias_autocomplete bb
fi

########################
# git shortcus
########################
if [ -f /usr/share/bash-completion/completions/git ]; then
  . /usr/share/bash-completion/completions/git

  alias g="git"
  complete -o default -o nospace -F _git g

  if [ -f ~/.bash_aliases_git ]; then
    . ~/.bash_aliases_git

    _git_delete() {
      _git_branch
    }

    alias gb="_g_begin"

    alias gd="_g_delete"
    complete -o default -o nospace -F _git_delete gd

    alias gp="_g_pr"

    alias gu="_g_sync"
  fi
fi

########################
# workspaces
########################
if [ -d $HOME/.workspace ]; then
  for d in $HOME/.workspace/*/; do
    ws=$(basename $d)
    source /dev/stdin << EOF
function create_${ws}() {
  if [ $# -eq 0 ]; then
    echo "Usage: create_dashing_ws <name>";
    exit 1;
  fi
  cp -r $d/. $1;
};
EOF
  done
fi
