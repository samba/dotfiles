#!/bin/sh


populate_params_stash () {
cat >> ${2} <<EOF
# Stashed properties from ~/.gitconfig
GIT_USER_NAME="`git config -f $1 --get user.name`"
GIT_USER_EMAIL="`git config -f $1 --get user.email`"
GITHUB_USER="`git config -f $1 --get github.user`"
GITHUB_EMAIL="`git config -f $1  --get github.email`"
GITHUB_TOKEN="`git config -f $1  --get github.token`"
EOF
}


restore_params_config () {
    test -f $2 && . $2 || return $?
    [ -z "${GIT_USER_NAME}" ] || git config -f $1  user.name "${GIT_USER_NAME}"
    [ -z "${GIT_USER_EMAIL}" ] || git config -f $1 user.email "${GIT_USER_EMAIL}"
    [ -z "${GITHUB_USER}" ] || git config -f $1 github.user "${GITHUB_USER}"
    [ -z "${GITHUB_EMAIL}" ] || git config -f $1  github.email "${GITHUB_EMAIL}"
    [ -z "${GITHUB_TOKEN}" ] || git config -f $1  github.token "${GITHUB_TOKEN}"
}

setup_ssh_keys () {
    test -d ~/.ssh || mkdir -m 0700 ~/.ssh
    test -f ~/.ssh/id_rsa && return 0
    echo "Preparing an SSH key..." >&2
    ssh-keygen -f ~/.ssh/id_rsa -C "${USER}@`hostname`" -b 4096

    # also setup common SSH paths
    mkdir -p ~/.ssh/keys ~/.ssh/sock
}

main () {

    path="$1";
    mode="$2";
    target="$path/.gitconfig"

    temp="${HOME}/.temp/gitconfig.`date +%Y%m%d-%H%M`"
    mkdir -p "${HOME}/.temp"

    case "$mode" in
        prepare) 
            test -f "$target" && populate_params_stash "$target" "$temp"
            setup_ssh_keys
        ;;
        restore) 
            test -f "$target" && restore_params_config "$target" "$temp"
        ;;
        clean)
            rm -rvf "$temp"
        ;;

        *)
            echo "(nothing for prepare.sh w/ ${mode})" >&2
        ;;
    esac
}

main "${@}"