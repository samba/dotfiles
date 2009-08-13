#!/bin/bash

SSH_AGENT_PID=${SSH_AGENT_PID:-0}
ps $SSH_AGENT_PID >/dev/null 2>/dev/null || { 

eval $(ssh-agent) >&2;

keys=$(mktemp)
for i in $(cat ~/.ssh/agent_keys 2>/dev/null); do
	[ -z "$i" ] && continue;
	[ -f "${HOME}/.ssh/$i" ] && echo ${HOME}/.ssh/$i
	[ -f $i ] && readlink -f $i
done > $keys


ssh-add $(cat $keys) >&2;

rm $keys

}
