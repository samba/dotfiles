# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

export MY_BASH=$HOME/.dotfiles/bash/
export DOTFILES=${HOME}/.dotfiles/
export PATH=${PATH}:${HOME}/.dotfiles/bin/

. $MY_BASH/lib.sh


setup_login_shell () {
	SKIP_DEFAULT=0 DEFAULT=auto ENTRYPT=bashrc.sh

	for i in $USER@$HOSTNAME $DEFAULT; do
		if [ $i = $DEFAULT ] && [ $SKIP_DEFAULT -gt 0 ]; then
			SKIP_DEFAULT=0
			continue;
		fi
		export p=$(get_shell_config $ENTRYPT "$i")
		[ -z "$p" ] && continue
		[ ! -f "$p" ] && continue
		. "$p"
	done

}

# load the enhancements for all login shells
is_login_shell && setup_login_shell


