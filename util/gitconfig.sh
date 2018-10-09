#!/bin/bash

set -euf -o pipefail

export CACHE="${CACHE:-${HOME}/.cache}"


# Generate a static script that restores the proper git config.
# This will make recovery easier in the event that a task somewhere else in this process fails.
function populate_params_stash () {
cat > ${2} <<EOF
#!/usr/bin/env sh
# Stashed properties from $1
GIT_USER_NAME="$(git config -f $1 --get user.name)"
GIT_USER_EMAIL="$(git config -f $1 --get user.email)"
GITHUB_USER="$(git config -f $1 --get github.user)"
GITHUB_EMAIL="$(git config -f $1  --get github.email)"
GITHUB_TOKEN="$(git config -f $1  --get github.token)"
GIT_SIGNING_KEY="$(git config --global --get user.signingkey)"
GIT_SIGN_COMMITS="$(git config --global --get commit.gpgsign)"


if test -f \$1; then
  git config -f \$1 user.name "\${GIT_USER_NAME}"
  git config -f \$1 user.email "\${GIT_USER_EMAIL}"
  git config -f \$1 user.signingkey "\${GIT_SIGNING_KEY}"
  git config -f \$1 commit.gpgsign "\${GIT_SIGN_COMMITS}"
  git config -f \$1 github.user "\${GITHUB_USER}"
  git config -f \$1 github.email "\${GITHUB_EMAIL}"
  git config -f \$1 github.token "\${GITHUB_TOKEN}"
else 
  echo "Could not find Git config file \$1" >&2
fi
EOF
}

function main () {
    test -d "${CACHE}" || mkdir -p "${CACHE}"
    case $1 in 
        stash) populate_params_stash "$2" "${CACHE}/restore_git.sh";;
        restore) test -f "${CACHE}/restore_git.sh" && source "${CACHE}/restore_git.sh" "$2";;
    esac
}

main "$@"