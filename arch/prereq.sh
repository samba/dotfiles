#!/usr/bin/env bash


install_pkg () {
	test $# -gt 0 || return 0
	sudo pacman -S --noconfirm "$@"
}

list_pkg () {
    command -v lsb_release >/dev/null 2>/dev/null || echo "lsb-release"
	command -v rsync >/dev/null 2>/dev/null || echo "rsync"
    command -v wget >/dev/null 2>/dev/null || echo "wget"
}


install_pkg $(list_pkg)

