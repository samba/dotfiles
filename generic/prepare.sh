#!/usr/bin/env bash

set -euf -o pipefail
# set -x

KEEP_CACHE="${KEEP_CACHE:-0}"



main () {

    path="$1";
    mode="$2";
    target="$path/.gitconfig"

    temp="${HOME}/.temp/gitconfig.`date +%Y%m%d-%H`"
    mkdir -p "${HOME}/.temp"

    case "$mode" ins
        clean)
            rm -rvf "$temp"
        ;;

        *)
            echo "(nothing for prepare.sh w/ ${mode})" >&2
        ;;
    esac
}

main "${@}"
