#!/bin/bash


# my favorite editor.
export EDITOR="/usr/bin/vim"

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


export BASH_SESSION_PATH="${HOME}/.bash_sessions.d"
[ ! -e "${BASH_SESSION_PATH}" ] && mkdir -p "${BASH_SESSION_PATH}"

PYTHONSTARTUP=~/.pythonrc

PATH="${PATH}:~/.dotfiles/bin/:~/Projects/SafeDesk/Tools/"
