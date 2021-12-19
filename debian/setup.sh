#!/usr/bin/bash

set -xeuf -o pipefail

fetch_command () {
    for k in curl wget; do
	case "$(basename "$(command -v $k)")" in
            curl) echo "$k -s"; return 0;;
            wget) echo "$k -q -O -"; return 0;;
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



main () {
case $1 in
    repos) setup_repositories "$0";;
    install)
        for role in ${2:-none}; do
            case $role in
                golang) bash ${PWD}/util/gosetup.sh install ;;
            esac
        done
        ;;
esac
}

main "$@"
