#!/usr/bin/env bash

# Loads SSH keys in a sensible fashion

if which ssh-agent >/dev/null; then
  eval "$(ssh-agent)"
  find ~/.ssh/ -name '*rsa' -print0 | xargs -0 ssh-add -K
fi

