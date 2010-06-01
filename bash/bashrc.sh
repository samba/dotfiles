# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

export MY_BASH=$HOME/.dotfiles/bash/
export PATH=${PATH}:${HOME}/.dotfiles/bin/

# an easy routine (named in english) for detecting whether this is a live login.
is_login_shell () { 
	[[ $0 =~ ^- ]] || [[ $- =~ i ]]
}

get_default_config () {
	local ent=$(basename $1)
	echo $MY_BASH/runtime-auto/$ent
}


setup_login_shell () {
	SKIP_DEFAULT=0 DEFAULT=auto

	for i in $USER@$HOSTNAME $DEFAULT; do
		export p=$MY_BASH/runtime-$i
		# echo $p >&2
		[ $i = $DEFAULT ] && [ $SKIP_DEFAULT -gt 0 ] && continue;
		[ -d $p ] && [ -f $p/bashrc.sh ] && . $p/bashrc.sh
	done

}

# load the enhancements for all login shells
is_login_shell && setup_login_shell


