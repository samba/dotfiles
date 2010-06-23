#!/bin/sh

# Load my keychain if an agent isn't already running
if ! ps -C ssh-agent >/dev/null; then
  keychain-auto
fi
