#!/usr/bin/env bash

set -euf -o pipefail

function get_package_handler () {
case $(uname -s) in 
    Darwin)
        which brew 2>/dev/null
        echo "none"  # this is a failure
        ;;
    Linux)
        which -a apt-get rpm pacman 2>/dev/null
        ;;
    *)
        echo "Unsupported system" >&2;;
esac
}


get_package_handler | head -n 1 | while read n; do
    basename "${n}"
done
