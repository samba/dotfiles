#!/bin/bash

SSH_AGENT_PID=${SSH_AGENT_PID:-0}
ps $SSH_AGENT_PID >/dev/null 2>/dev/null && exit 0

eval $(ssh-agent)

keys=$(mktemp)
for i in $(cat ~/.ssh/agent_keys); do
	[ -z "$i" ] && continue;
	[ -f "${HOME}/.ssh/$i" ] && echo ${HOME}/.ssh/$i
	[ -f $i ] && readlink -f $i
done > $keys


ssh-add $(cat $keys);

rm $keys

