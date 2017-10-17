#!/usr/bin/env bash

[-z "$SSH_AGENT_PID" ] || ssh-agent -k
