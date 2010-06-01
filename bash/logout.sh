# ~/.bash_logout: executed by bash(1) when login shell exits.

export MY_BASH=$HOME/.dotfiles/bash/
. $MY_BASH/lib.sh


cleanup_login_shell () {
	SKIP_DEFAULT=0 DEFAULT=auto

	for i in $USER@$HOSTNAME $DEFAULT; do
		if [ $i = $DEFAULT ] && [ $SKIP_DEFAULT -gt 0 ]; then
			SKIP_DEFAULT=0
			continue;
		fi
		export p=$(get_shell_config logout.sh $i)
		[ -f $p ] && . $p
	done
}

is_login_shell && cleanup_login_shell
