#!/usr/bin/env bash

# Compare the live state of user's dotfiles against the current state of this
# repository directory. This enables easy review of the live environment as it
# has varied over time from a past dotfiles deployment.


REPO_PATH="$(dirname $(dirname $0))"

list_dotfiles () {
    find ${1} -type f   -print  | sed "s@^${1}@@"
}

scan_diff_dotfiles () {
    local srcpath="${REPO_PATH}/dotfiles"
    local base="${1}";
    shift 1;
    while read versioned_file; do
        diff -N -w -U 3 $@ \
            "${srcpath}/${versioned_file}" \
            "${base}/${versioned_file}" \
            || true
    done < <(list_dotfiles "${srcpath}")
}

# set -x -e
scan_diff_dotfiles "${1:-${HOME}}" 

