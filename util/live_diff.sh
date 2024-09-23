#!/usr/bin/env bash

# Compare the live state of user's dotfiles against the current state of this
# repository directory. This enables easy review of the live environment as it
# has varied over time from a past dotfiles deployment.


REPO_PATH="$(dirname $(dirname $0))"

list_dotfiles () {
    find ${1} -type f -print | sed "s@^${1}@@" | grep -v '.session.vim' # the general case
}


list_nonmatching_files () {
    local srcpath="${REPO_PATH}/dotfiles"
    local base="${1}";
    shift 1;
    while read versioned_file; do
        diff -q "${srcpath}/${versioned_file}" "${base}/${versioned_file}" 1>/dev/null 2>/dev/null \
            || printf "%q\t%q\n" "${srcpath}/${versioned_file}" "${base}/${versioned_file}"
    done

}


print_patchdiff () {
    diff -N -w -U 3 $@ || true
}


case "${1}" in
    list)  list_dotfiles "${REPO_PATH}/dotfiles" | list_nonmatching_files "${2:-${HOME}}" ;;
    print) list_dotfiles "${REPO_PATH}/dotfiles" | list_nonmatching_files "${2:-${HOME}}" | while read s d; do print_patchdiff "${s}" "${d}"; done
        ;;
esac
