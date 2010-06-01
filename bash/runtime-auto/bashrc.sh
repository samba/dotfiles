#!/bin/sh

[ -f /etc/bashrc ] && . /etc/bashrc

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
[ -f /etc/bash_completion ] && . /etc/bash_completion
[ -f /etc/profile.d/bash-completion.sh ] && . /etc/profile.d/bash-completion.sh


x=$(dirname $p)

# pull in my standard configuration elements
for i in aliases color.sh prompt.sh; do
  [ -f $x/$i ] && . $x/$i
done

exit_handler () {
	is_login_shell && printf "exit: %s@%s\n" "$USER" "$HOSTNAME" >&2
}



# set the mail location, notification options
export MAILPATH="/var/mail/${USER}?You have mail:~/.mbox?$_ has mail!"
shopt -s mailwarn # keep an eye on the mail files (access time)

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# correct spelling mistakes
shopt -s cdspell

# look at variables that might hold directory paths
# shopt -s cdable_vars

# tab-completion of hostnames after @
shopt -s hostcomplete


# also write command history at every prompt.
PROMPT_COMMAND=" history -a; ${PROMPT_COMMAND} "


# don't put duplicate lines in the history. See bash(1) section 'HISTORY' for more options
export HISTCONTROL="ignoredups"

# ... and ignore same sucessive entries, as well as commands starting with a space.
export HISTCONTROL="ignoreboth" 

# store more stuff in the history...
export HISTSIZE=225175
export HISTFILESIZE=10000
export HISTTIMEFORMAT="[%F-%T] " # puts full date and time in history display.

# ignore relatively meaningless commands.
export HISTIGNORE="fg*:bg*:history*"

shopt -s histappend # makes bash append to history rather than overwrite

# store multiline commands as single entries in history file
shopt -s cmdhist

# allow re-editing of a history command substitution, if the previous run failed
shopt -s histreedit

# my favorite editor.
export EDITOR="/usr/bin/vim"
export VIMRUNTIME=`vim -e -T dumb --cmd 'exe "set t_cm=\<C-M>"|echo $VIMRUNTIME|quit' | tr -d '\015' `

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


export PYTHONSTARTUP=${HOME}/.pythonrc.py


trap exit_handler EXIT


