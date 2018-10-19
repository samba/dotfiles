#!/usr/bin/env bash

# This is a shortcut to allow ad-hoc app installation, without generating
# the script artifacts the Makefile expects.

base="$(dirname $0)"
script="$(mktemp ${base}/install.sh.XXXXXX)"
roles="${@}"

test $# -eq 0 && roles="desktop developer user-cli security libs python"

python "${base}/packages.py" \
    -i "${base}/packages.index.csv" \
    "${roles}" > ${script}

bash -x ${script}
rm -v ${script}

