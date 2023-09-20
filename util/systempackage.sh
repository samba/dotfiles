#!/usr/bin/env bash

set -euf -o pipefail

function get_package_handler () {
case $(uname -s) in 
    Darwin)
        command -v brew 2>/dev/null
        echo "none"  # this is a failure
        ;;
    Linux)
        for a in apt-get yum pacman; do
            command -v ${a} 2>/dev/null
        done
        ;;
    *)
        echo "Unsupported system" >&2;;
esac
}


get_package_handler | head -n 1 | while read n; do
    basename "${n}"
done
