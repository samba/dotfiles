#!/usr/bin/env bash

set -euf -o pipefail

function require_sudo () {
    sudo -v && return 0 # get password earlier...
    echo "Cannot prepare system without sudo." >&2
    return 1
}


function requires () {
    which $1 >/dev/null && return 0
    echo "no executable resolved: $1" >&2
    return 1
}


function get_package_handler () {
case $(uname -s) in 
    Darwin)
        echo "brew";;
    Linux)
        basename $(which apt-get rpm | head -n 1);;
    *)
        echo "Unsupported system" >&2;;
esac
}

function install_homebrew () {
    requires xcodebuild  "Please install XCode from the App Store." || return 1

    echo "Installing Homebrew..." >&2
    require_sudo

    set -e
    sudo xcodebuild -checkFirstLaunchStatus
    [ $? -eq 69 ] || sudo xcodebuild -license

    sudo xcode-select --install

    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

    set +e
}

function install_as_needed () {
    while read executable; do
        case "${executable}" in 
            brew)
                requires brew || install_homebrew
        esac
        echo ${executable}   # print only one package handler
        break
    done

}

get_package_handler | install_as_needed