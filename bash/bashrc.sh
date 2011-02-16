# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

export DOTFILES=${HOME}/.dotfiles/
export PATH=${PATH}:${DOTFILES}/bin/

. $DOTFILES/bash/lib.sh

# NOTE: we're rescanning *every time* right now until this stabilizes
dotfiles -s >/dev/null


setup_login_shell () {
  dotfiles -q '(*.)\.sh$' | while read i; do
    echo '#' ${DOTFILES}/$i >&2
    . ${DOTFILES}/$i
  done
}

# load the enhancements for all login shells
is_login_shell && setup_login_shell


