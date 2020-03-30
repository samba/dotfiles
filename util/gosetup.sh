#!/usr/bin/env bash

set -euf -o pipefail

fail () {
    echo "$2" >&2
    exit $1
}

test -z "${GOPATH}" && fail 1 "Please define \$GOPATH environment"


mkdir -p ${GOPATH}/{bin,src}

