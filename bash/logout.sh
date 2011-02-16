# ~/.bash_logout: executed by bash(1) when login shell exits.

. ${DOTFILES}/bash/lib.sh

cleanup_login_shell () {
  : # do nothing
}

is_login_shell && cleanup_login_shell
