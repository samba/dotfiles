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

install_system_libs () {
    requires wget || brew::notify install wget
    requires openssl || brew::notify install openssl
    brew::notify install libffi libgit2 jpeg
}

install_python_base () {
    which pip && return 0
    install_system_libs
    sudo easy_install pip
    sudo -H pip install --upgrade --ignore-installed six python-dateutil
}


install_containers () {
    # Container and Virtual Machine environments

    requires kubectl || brew::notify install kubernetes-cli
    requires xhyve || brew::notify install xhyve
    requires minikube || brew::notify cask install minikube


    # brew install compose2kube
    # brew install docker-compose
    brew install docker-clean

    # Docker's official release.
    brew cask install docker

    brew cask install vagrant vagrant-manager
    brew cask install virtualbox virtualbox-extension-pack

}

install_cloudutils () {
    install_python_base
    requires gcloud || brew::notify cask install google-cloud-sdk
}

install_usermode () {
    # Various GUI utilities
    brew::notify cask install iterm2

    # Sadly this is required...
    brew::notify cask install java

    # Security kit
    brew::notify install gnupg
    brew::notify cask install veracrypt
    brew::notify cask install gpg-suite


    # File sharing and software distribution kit
    brew::notify cask install transmission
    brew::notify cask install cyberduck
    brew::notify install p7zip


    # Developer tools
    brew::notify install github-keygen
    brew::notify install terminal-notifier
    brew::notify install bfg # requires Java
    brew::notify cask install macdown # fail
    brew::notify cask install github
    brew::notify cask install fork


    # Productivity etc
    brew::notify cask install caffeine
    brew::notify cask install oversight



    # Powerline fonts
    brew search --casks "/font-.*-for-powerline/" 2>/dev/null | tail -n +2 | xargs -t brew cask install
}

install_nodejs () {
    requires node || brew::notify install node 
}

install_webdev ()  {
    install_python_base
    brew::notify cask install postman
    brew::notify install closure-compiler
}

install_pythondev () {
    install_python_base
    requires python3 || brew::notify install python3
}

install_database () {

    requires mysql || brew::notify install mysql
    requires psql || brew::notify install postgresql
    requires mongodb || brew::notify install mongodb 
    
    brew::notify cask install \
        mysqlworkbench \
        mongodbpreferencepane

    # Set up MySQL to launch automatically
    mkdir -p ~/Library/LaunchAgents
    find "$(brew --prefix mysql)" -type f -name '*.plist' | while read f; do
        cp -v "${f}"  ~/Library/LaunchAgents/
        launchctl load -w "~/Library/LaunchAgents/$(basename "${f}")"
    done
    
}

install_golang () {
    requires go || brew::notify install go
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

    path="$1";
    mode="$2";

    case $mode in 
        prepare|restore|clean|dotfiles) return 0 ;;
    esac

    require_sudo || return $?
    install_homebrew || return $?
    install_system_libs

    case "$mode" in
        containers) install_containers ;;
        cloud) install_cloudutils ;;
        database) install_database ;;
        golang) install_golang ;;
        nodejs) install_nodejs ;;
        webdev) 
            install_nodejs
            install_pythondev
            install_webdev
        ;;
        python) 
            install_python_base
            install_pythondev
        ;;
        usermode)
            install_usermode
            setup_git_osx_keychain
        ;;
        all)
            install_usermode
            setup_git_osx_keychain
            install_containers
            install_cloudutils
            install_webdev
            install_pythondev
            install_nodejs
            install_golang
            install_database
        ;;
    esac
}


main "${@}"
exit $?
