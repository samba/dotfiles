#!/bin/sh

# Load my keychain if an agent isn't already running
ps -C ssh-agent || keychain-auto
