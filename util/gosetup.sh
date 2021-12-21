#!/usr/bin/env bash

# Sets up the workspace structure I like for Go projects.
# If passed "install" as first argument, also performs a download/install direct from golang.org

set -euf -o pipefail

GOVERSION=1.17

fail () {
    echo "$2" >&2
    exit $1
}

test -z "${GOPATH-}" && fail 1 "Please define \$GOPATH environment"

mkdir -p ${GOPATH}/{bin,src}

install_go () {
    fname="go${1}.${2,,}-${3}.tar.gz"
    rungo=/usr/local/go/bin/go

    # Skip if present Go binary is the correct version
    test -x $rungo && $rungo version | grep "go${GOVERSION}" && return 0

    # Proceed to download and install
    wget -c https://golang.org/dl/${fname} -O /tmp/${fname}
    echo "# Installing Go ${GOVERSION} in /usr/local/go/"
    sudo tar -zxf /tmp/${fname} -C /usr/local/
}


_do_golang_installation () {

    if ! command -v go; then
        os_platform=$(uname -a | grep -oE '(Darwin|Linux)' | head -n 1)
        case $(uname -a | grep -oE '(i386|amd64|x86_64)' | head -n 1) in
            i386) install_go $GOVERSION $os_platform i386;;
            amd64|x86_64) install_go $GOVERSION $os_platform amd64;;
        esac
    fi

}

case "${1-}" in
    install) _do_golang_installation ;;
esac
