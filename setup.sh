#!/bin/sh

sync_dotfiles () {
    read -p "This will wipe out your existing dotfiles. Please confirm. [yn]" -n 1
    echo ""
    test "$REPLY" = "y" || return 1
    rsync ${1}/dotfiles/ ${2}/ \
        --exclude ".git/" \
        --exclude ".osx" \
        --exclude ".DS_Store" \
        --exclude "*.md" \
        --exclude "*.txt" \
        -arvh --no-perms --no-links
}

find_install_scripts () {
    set -e
    case "`uname -s`" in
        Darwin)  
            find ${1}/macos/ -type f -name '*.sh' | sort
            ;;
        Linux)
            which apt-get && find ${1}/debian/ -type f -name '*.sh' | sort
            ;;
        *)
            echo "Unrecognized operating system: [`uname -s`]" >&2
            ;;
    esac

    find ${1}/generic/ -type f -name '*.sh' | sort

    set +e
}

run_scripts () {
    while read f; do
        echo "## Executing: ${f} ${1} ${2}" >&2
        test -f "${f}" && sh "${f}" "${1}" "${2}" "${3}"
    done
}


do_install () {
    # script_base=$1, $mode=$2, target_path=$3
    find_install_scripts "$1" | run_scripts "${3}" "${2}" "${1}"
}


print_help () {
cat <<EOF
Usage: $0 <mode> \$HOME [ -o <options> ]

Mode can be one of:

- dotfiles  # synchronizes configuration
- apps      # installs a variety of useful software

Options represent classes of tooling to install for 
various kinds of development. Case sensitive.
This paramter is only meaningful for the "apps" mode.

- all
- usermode
- cloud
- containers
- database
- golang
- python
- nodejs
- webdev

Some overlap may occur between these modes.

EOF
exit 1
}

main () {
    test "$#" -gt 1 || print_help
    test -n "$2" && test -d "$2" || print_help
    
    mode="$1";  # which parts to install/etc
    path="$2";  # where to install it
    shift 2;


    case "$mode" in
        dotfiles)
            do_install "$(dirname $0)" "prepare" "$path"
            sync_dotfiles "$(dirname $0)" "$path"
            do_install "$(dirname $0)" "dotfiles" "$path"
            do_install "$(dirname $0)" "restore" "$path"
            do_install "$(dirname $0)" "clean" "$path"
        ;;
        apps)
            while getopts :o: Option; do
                case $Option in
                    o) 
                        do_install "$(dirname $0)" "$OPTARG" "$path"
                    ;;
                esac
            done
        ;;
        *) 
            echo "(${@})" >&2
            print_help
            
        ;;
    esac
}



main "${@}"