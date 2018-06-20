#!/usr/bin/env bash

# Loads SSH keys in a sensible fashion


ssh_agent_avail () {
		test -z "$SSH_AGENT_PID" && return 1
		test -r "$SSH_AUTH_SOCK" || return 1 
		shopt -q login_shell || return 1
		which ssh-add >/dev/null || return 1
}

configure_ssh_agent () {
	# automatically add keychain-provided keys
	ssh-add -q -A 1>/dev/null 2>/dev/null

	# Discover keys that are not already known
	find "${HOME}/.ssh" -type f -name '*rsa' \
		| grep -v -f <(ssh-add -l 2>/dev/null | cut -d ' ' -f 3) \
		| xargs ssh-add -q -K 1>/dev/null   2>/dev/null


	# List known keys
	# ssh-add -l
}

if shopt -q login_shell; then
	which ssh-agent >/dev/null && \
		test -z "$SSH_AGENT_PID" && \
		eval "$(ssh-agent -s 2>/dev/null)" 1>/dev/null
	ssh_agent_avail && configure_ssh_agent
	echo
fi

