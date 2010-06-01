# ~/.bashrc: executed by bash(1) for non-login shells.
# should not generate any output


# TODO do we need this for non-login shells?
[ -f /etc/bashrc ] && source /etc/bashrc


export IS_LOGIN_SHELL=no
if [[ $0 =~ ^- ]] || [[ $- =~ i ]]; then
  export IS_LOGIN_SHELL=yes
fi

# load env for login shells
if [ $IS_LOGIN_SHELL = 'yes' ]; then
  [ -e ~/.bash_aliases ] && source ~/.bash_aliases
  # FIXME why do we load them twic?
  [ -e ~/.dotfiles/bash/aliases.sh ] && source ~/.dotfiles/bash/aliases.sh

  [ -f /etc/profile.d/bash-completion.sh ] && source /etc/profile.d/bash-completion.sh

  # Appending instead of overwriting
  shopt -s histappend

  # Store multiline commands as single entries in history file
  shopt -s cmdhist

  export HISTSIZE=100001
  export HISTCONTROL="ignoreboth" # ignoredups && ignorespace
  export HISTTIMEFORMAT="[%F-%T] " # puts full date and time in history display.
  export HISTIGNORE="fg*:bg*:history*"

  export EDITOR="/usr/bin/vim -p"

  export PATH=${PATH}:${HOME}/.dotfiles/bin:${HOME}/bin

  # Will be non-empty if shad is available
  export SHAD_HOME=""

  load_env () {
    if [ -d ${HOME}/.dotfiles/bash/env.d/$1 ]; then
      for i in ${HOME}/.dotfiles/bash/env.d/$1/*.sh; do
        source $i
      done
    fi
  }

  host=$HOSTNAME
  # check whether we have a domain within the hostname
  if [[ $HOSTNAME =~ \. ]]; then
    host=${HOSTNAME/.*/}
    domain=${HOSTNAME/*./}
  fi
  if [ -f ~/.dotfiles/bash/env-${host}.sh ]; then
    source ~/.dotfiles/bash/env-${host}.sh
  else
    source ~/.dotfiles/bash/env.sh
  fi

  # if there was a domain in the hostname we overwrite it here
  if [ -n "$domain" ]; then
    export DOTFILES_ENV_DOMAIN=$domain
  fi

  [ -n "$DOTFILES_ENV_TYPE" ] && load_env type/$DOTFILES_ENV_TYPE
  [ -n "$DOTFILES_ENV_DOMAIN" ] && load_env domain/$DOTFILES_ENV_DOMAIN
  [ -n "$DOTFILES_ENV_DIST" ] && load_env dist/$DOTFILES_ENV_DIST
  load_env host/$host


  [ -f ~/.dotfiles/bash/prompt.sh ] && source ~/.dotfiles/bash/prompt.sh

  for i in ~/.dotfiles/bash/tools/*; do 
    source $i
  done

  unset load_env
fi

exit_handler () {
  [ $IS_LOGIN_SHELL = 'yes' ] && printf "exit: %s@%s [%s:%s]\n" "$USER" "$HOSTNAME" "$DOTFILES_ENV_TYPE" "$DOTFILES_ENV_DOMAIN" >&2
}

trap exit_handler EXIT


