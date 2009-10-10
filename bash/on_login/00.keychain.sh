#!/bin/bash

[ $isLoginShell = 'yes' ] || return 0 

# because this script runs as part of core, avoid writing to stdout
k=$(which keychain)
if [ -z "$k" -o ! -x "$k" ]; then
	echo "Keychain not available. Please install it or use 'ssh-agent'." >&2
else
	echo 'Loading keychain: ' $k >&2
	$k $(cat ~/.ssh/agent_keys) 1>&2
fi

