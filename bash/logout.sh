# ~/.bash_logout: executed by bash(1) when login shell exits.

. ${DOTFILES}/bash/lib.sh

cleanup_login_shell () {
  for i in `dotfiles -q logout.sh`; do
    . $DOTFILES/$i
  done
}

is_login_shell && cleanup_login_shell
