#!/bin/bash
# This script is intended to be run in Debian Linux (or similar)
# It 


set -euf -o pipefail

# This notation only works in bash. Wee!
function prepare () {
    grep -v '=' Makefile | egrep -o '^(\w+):'
    make dotfiles
}

echo "Running tests..." >&2

prepare $1