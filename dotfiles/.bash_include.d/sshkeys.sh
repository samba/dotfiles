#!/usr/bin/env bash

# Loads SSH keys in a sensible fashion

ssh_agent_avail () {
		test -z "$SSH_AGENT_PID" && return 1
		test -r "$SSH_AUTH_SOCK" || return 1 
		shopt -q login_shell || return 1
		which ssh-add >/dev/null || return 1
}

configure_ssh_agent () {

	ssh-add -q -A  # automatically add keychain-provided keys

	# Discover keys that are not already known
	find "${HOME}/.ssh" -type f -name '*rsa' \
		| grep -v -f <(ssh-add -l | cut -d ' ' -f 3) \
		| xargs ssh-add -q -K


	# List known keys
	ssh-add -l
}

if shopt -q login_shell; then
	test -z "$SSH_AGENT_PID" && eval "$(ssh-agent -s)"
	ssh_agent_avail && configure_ssh_agent
	echo
fi



