#!/usr/bin/env bash



[ -n "$SSH_AGENT_PID" ] && [ -z "$STY" ] && ssh-agent -k
