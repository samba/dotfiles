#!/usr/bin/env bash

set -euf -o pipefail

require_sudo () {
    sudo -v && return 0 # get password earlier...
    echo "Cannot prepare system without sudo." >&2
    return 1
}


requires () {
    which $1 && return 0
    echo "no executable resolved: $1" >&2
    return 1
}


install_homebrew () {
    which brew && return 0
    requires xcodebuild  "Please install XCode from the App Store." || return 1

    set -e

    sudo xcodebuild -checkFirstLaunchStatus
    [ $? -eq 69 ] || sudo xcodebuild -license

    sudo xcode-select --install

    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

    set +e
    return 0
}

brew::notify () {
   brew ${@} && return $?
   echo "!!! installation failed: brew $@" >&2
}

install_python_base () {
    which pip && return 0
    install_system_libs
    sudo easy_install pip
    sudo -H pip install --upgrade --ignore-installed six python-dateutil
}


install_fonts () {
    # Powerline fonts
    requires brew || return $?
    brew search --casks "/font-.*-for-powerline/" 2>/dev/null | tail -n +2 | xargs -t brew cask install
}

autostart_mysql () {
    # Set up MySQL to launch automatically
    find "$(brew --prefix mysql)" -type f -name '*.plist' | while read f; do
        mkdir -p ${HOME}/Library/LaunchAgents
        cp -v "${f}"  ${HOME}/Library/LaunchAgents/
        launchctl load -w "${HOME}/Library/LaunchAgents/$(basename "${f}")"
    done
}

setup_git_osx_keychain () {

    git config --global credential.helper osxkeychain
    which git-credential-osxkeychain || return 0


    # Install the credential helper
    require_sudo
    requires curl || fail 2 "requires \`curl\` to install git-credential-osxkeychain"
    sudo curl -s -O http://github-media-downloads.s3.amazonaws.com/osx/git-credential-osxkeychain \
        -o "$(dirname $(which git))/git-credential-osxkeychain"
    sudo chmod u+x "$(dirname $(which git))/git-credential-osxkeychain"

}


main () {

    case $1 in
        install)
            install_homebrew
            install_python_base
            install_fonts 
            ;;
        configure)
            autostart_mysql
            setup_git_osx_keychain
            ;;
    esac

}


main "${@}"
exit $?
