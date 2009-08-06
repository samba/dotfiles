# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples


if [ -f /etc/bashrc ]; then
. /etc/bashrc
fi


# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

# I did. This script just calls those.
# See ~/.bash_aliases and ~/.bash.d/ for real content. 

# drop out if we are not in a login/interactive shell
export isLoginShell=no
if [[ $0 =~ ^- ]] || [[ $- =~ i ]]; then
    export isLoginShell=yes
fi


# Load all core scripts - these should NOT produce any output
# as this can interfere with tools that pipe over SSH, e.g. unison
for i in ${HOME}/.bash.d/core/*.sh; do
    source $i;
done


# load the enhancements for all login shells
[ $isLoginShell = 'yes' ] && {
    [ -e ~/.bash_aliases ] && source ~/.bash_aliases
    [ -e ~/.bash.d/aliases ] && source ~/.bash.d/aliases
    for i in ${HOME}/.bash.d/onlogin/*.sh; do
	source $i;
    done

}

function exit_handler () {
	for i in ${HOME}/.bash.d/onexit/*.sh; do
		source $i
	done
}

trap exit_handler EXIT
