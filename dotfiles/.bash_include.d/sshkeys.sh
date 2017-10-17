#!/usr/bin/env bash

# Loads SSH keys in a sensible fashion

configure_ssh_agent () {
	test -z "$PS1" && return 0
	test -z "$SSH_AGENT_PID" && return 0
	test -e "$SSH_AUTH_SOCK" || return 0 
  which ssh-add >/dev/null && find ~/.ssh/ -name '*rsa' -print0 | xargs -0 ssh-add -K
}

configure_ssh_agent

