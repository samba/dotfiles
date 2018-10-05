#!/usr/bin/env bash

set -euf -o pipefail

function get_package_handler () {
case $(uname -s) in 
    Darwin)
        which brew
        echo "none"  # this is a failure
        ;;
    Linux)
        which -a apt-get rpm 
        ;;
    *)
        echo "Unsupported system" >&2;;
esac
}


get_package_handler | head -n 1 | while read n; do
    basename "${n}"
done