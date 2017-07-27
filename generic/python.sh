#!/usr/bin/env bash

require_sudo () {
    sudo -v && return 0 # get password earlier...
    echo "Cannot prepare system without sudo." >&2
    return 1
}

setup_custom_load () {
    require_sudo || return $?
    python -c "import site; print site.getusersitepackages()" | while read p; do
        sudo cp -v "$1/misc/usercustomize.py" "$p/usercustomize.py"
    done
}

install_pythondev () {
    require_sudo || return $?
    sudo -H pip install \
        virtualenv vex \
        coverage nose unittest2 \
        pep8 pyflakes flake8 pylint \
        Jinja2 Pillow \
        lesscpy
}

main () {

    path="$1";
    mode="$2";
    base="$(dirname $0)";

    case $mode in
        prepare|restore|clean) return 0 ;;
    esac

    case "$mode" in
        dotfiles)
            setup_custom_load "$base"
        ;;
        python)
            install_pythondev
        ;;
        all)
            setup_custom_load "$base"
            install_pythondev
        ;;
    esac
}
main "${@}"