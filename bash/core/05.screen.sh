#!/bin/bash


# screen integration.
# if GNU screen is present, automitically start a 'default' session, or reattach to it if it already exists.

# Ideally this should be run early in the session, as other utilities may depend on it.

[ -z $NOSCREEN ] || return
[ "$isLoginShell" = 'yes' ] || return
# if present
if  which screen > /dev/null; then 
    screen -wipe > /dev/null

   
    # if a 'default' session does not exist, create a new one in the background
    screen -ls | grep -E '[0-9]+.default' > /dev/null || {
	echo "Creating default screen session" >&2
	[ $USER != 'root' ] && [ $UID -ne 0 ] && screen -d -m -S default 
    }


    # if i'm already in screen...
    if [[ "$TERM" =~ 'screen' ]]; then
    	# load scripts in the inscreen directory
	for i in ${HOME}/.bash.d/inscreen/*.sh; do
	    source $i;
	done
    else
	# set the terminal type properly
	# wrap to simplify work from multiple locations
	alias scr="screen -T ${TERM} -rx -S default"

	# automatically join the screen session (only if NOSCREEN isn't set)
	[ -n $NOSCREEN ] || screen -T ${TERM} -rx -S default
    fi

fi


# if we're in a screen session (and a login shell), print the name
[ ! -z "$STY" ] && [ ! -z "$PS1" ] && {
    echo "You are in screen session: $STY" >&2
}
