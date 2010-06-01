#!/bin/bash

[ $IS_LOGIN_SHELL = 'yes' ] || return 0

# because this script runs as part of core, avoid writing to stdout
if which keychain 1>/dev/null 2>&1; then
  if [ -f ~/.ssh/autoload ]; then
    keychain -q $(<~/.ssh/autoload) 1>&2
    source ~/.keychain/$HOSTNAME-sh
    [ -f ~/.keychain/$HOSTNAME-sh-gpg ] && source ~/.keychain/$HOSTNAME-sh-gpg
  fi
fi



