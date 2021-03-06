#!/bin/bash
# This script is intended to be run in Debian Linux (or similar)
# It is NOT expected to work well directly on the repo, or on a Mac.

set -euf -o pipefail

# This notation only works in bash. Wee!
function prepare () {
    SSHKEY_PASSWORD="thisisatest" make dotfiles
    make @install_packages
}

echo "Running tests..." >&2

prepare $1