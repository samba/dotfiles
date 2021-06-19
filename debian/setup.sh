#!/usr/bin/bash

set -xeuf -o pipefail

fetch_command () {
    for k in curl wget; do
        command -v $k || continue
        case $k in
            curl) echo "-s"; break;;
            wget) echo "-q -O -"; break;;
        esac
    done
}

fetch () {
    while read target; do 
        temp=$(mktemp /tmp/"$(basename "${target}").XXXXXX")
        $(fetch_command) "${target}" > ${temp}
        echo "$temp"
    done
}

keys () {
    # Allow Kubernetes package repositories to be signed
    echo https://packages.cloud.google.com/apt/doc/apt-key.gpg
}

setup_repositories () {

    apt-get update
    apt install -y apt-transport-https

    # Register all the keys
    keys | fetch | while read k; do
        apt-key add "$k"
        rm -v "$k"
    done

    rsync -av $(dirname "$1")/sources.list.d/ /etc/apt/sources.list.d/

    apt-get update
}


_do_golang_installation () {
    go_archive="go1.13.linux-amd64.tar.gz"
    $(fetch_command) https://dl.google.com/go/${go_archive} > /tmp/${go_archive}
    sudo tar -C /usr/local -xzf /tmp/${go_archive}
}


main () {
case $1 in
    repos) setup_repositories "$0";;
    install)
        for role in ${2:-none}; do
            case $role in
                golang) _do_golang_installation;;
            esac
        done
        ;;
esac
}

main "$@"
