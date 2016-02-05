#!/bin/sh


setup_sshkeys () {
  if [ "${SKIP_SSHKEYS}" -eq "true" ]; then
    echo "Skipping SSH key generation."
    return 0
  fi
  if [ ! -f "${HOME}/.ssh/id_rsa" ]; then
    echo "# Preparing SSH key files (enter passphrase; empty is OK)" >&2
    ssh-keygen -b 2048 -f "${HOME}/.ssh/id_rsa"
  fi
}


