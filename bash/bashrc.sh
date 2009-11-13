# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

if [ -f /etc/bashrc ]; then
. /etc/bashrc
fi

# drop out if we are not in a login/interactive shell
export isLoginShell=no
if [[ $0 =~ ^- ]] || [[ $- =~ i ]]; then
    export isLoginShell=yes
fi


# load the enhancements for all login shells
if [ $isLoginShell = 'yes' ]; then
	export VIMRUNTIME=`vim -e -T dumb --cmd 'exe "set t_cm=\<C-M>"|echo $VIMRUNTIME|quit' | tr -d '\015' `
	[ -e ~/.bash_aliases ] && source ~/.bash_aliases
	[ -e ~/.dotfiles/bash/aliases ] && source ~/.dotfiles/bash/aliases
	
#	for i in ${HOME}/.dotfiles/bash/on_login/*.sh; do
#		source $i;
#	done

	[ -f ~/.dotfiles/bash/color.sh ] && source ~/.dotfiles/bash/color.sh
	[ -f ~/.dotfiles/bash/prompt.sh ] && source ~/.dotfiles/bash/prompt.sh

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

	# enable programmable completion features (you don't need to enable
	# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
	# sources /etc/bash.bashrc).
	if [ -f /etc/bash_completion ]; then
			source /etc/bash_completion
	fi

	if [ -f /etc/profile.d/bash-completion.sh ]; then
			source /etc/profile.d/bash-completion.sh
	fi


	# also write command history at every prompt.
	PROMPT_COMMAND=" history -a; ${PROMPT_COMMAND} "


	# don't put duplicate lines in the history. See bash(1) section 'HISTORY' for more options
	export HISTCONTROL="ignoredups"

	# ... and ignore same sucessive entries, as well as commands starting with a space.
	export HISTCONTROL="ignoreboth" 

	# store more stuff in the history...
	export HISTSIZE=10000
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

	# make less more friendly for non-text input files, see lesspipe(1)
	[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


	export PYTHONSTARTUP=${HOME}/.pythonrc

	export PATH=${PATH}:${HOME}/.dotfiles/bin/

fi

function exit_handler () {
	for i in ${HOME}/.dotfiles/bash/on_exit/*.sh; do
		source $i
	done
}

trap exit_handler EXIT
