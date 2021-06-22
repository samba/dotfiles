#!/usr/bin/env bash


install_pkg () {
	test $# -gt 0 || return 0
	sudo apt-get install -y "$@"
}

list_pkg () {
	which rsync >/dev/null || echo "rsync"
}


install_pkg $(list_pkg)

