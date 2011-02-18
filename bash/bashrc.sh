# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

export DOTFILES=${HOME}/.dotfiles/
export PATH=${PATH}:${DOTFILES}/bin/

. $DOTFILES/bash/lib.sh

# NOTE: we're rescanning *every time* right now until this stabilizes
# dotfiles -s >/dev/null

# Dotfiles loader
dotfiles_loader (){
  wholepath=$1; shift;
  for pattern in $@; do
    for i in `dotfiles -q "$pattern" $wholepath`; do
      export CURRENT=${DOTFILES}/$i
      echo '# loading' $CURRENT
      . $CURRENT
    done
  done

}

# user-friendly shortcut
df () {
  dotfiles_loader '' "^$1\.df\.sh$"
}


setup_login_shell () {
  # all files named 'bashrc.sh' or '*.auto.sh'
  dotfiles_loader '' 'aliases|(bashrc|(.*)\.auto)\.sh$'

  # background loading of all .bg.sh
  dotfiles_loader '' '(.*)\.bg\.sh$'
}

# load the enhancements for all login shells
is_login_shell && time setup_login_shell

