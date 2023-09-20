#!/bin/bash

install_prereq () {
	test $# -gt 0 || return 0
	sudo pacman -S --needed --noconfirm "$@"
}


setup_yay () {
    mkdir -p /opt/yay
    cd /opt/yay
    pacman -S --needed git base-devel && \
        git clone https://aur.archlinux.org/yay-bin.git && \
        cd yay-bin && \
        makepkg -si
}

# this follows the same style as the debian kit
setup_repositories () {
    install_prereq rsync wget
    setup_yay
}


main () {
case $1 in
    repos)  setup_repositories "$@";;
    install)
        for role in ${2:-none}; do
            case $role in
                idunno) do_nothing ;;  # this is a placeholder
            esac
        done
        ;;
esac
}



