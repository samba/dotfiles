#!/bin/sh

require_sudo () {
    sudo -v && return 0 # get password earlier...
    echo "Cannot prepare system without sudo." >&2
    return 1
}


requires () {
    which $1 && return 0
    echo "$2" >&2
    return 1
}


install_homebrew () {
    which homebrew && return 0
    requires xcodebuild  "Please install XCode from the App Store." || return 1

    set -e

    sudo xcodebuild -checkFirstLaunchStatus
    [ $? -eq 69 ] || sudo xcodebuild -license

    sudo xcode-select --install

    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

    set +e
    return 0
}

install_system_libs () {
    brew install libffi libgit2 openssl wget jpeg
}

install_python_base () {
    which pip && return 0
    install_system_libs
    sudo easy_install pip
    sudo -H pip install --upgrade --ignore-installed six python-dateutil
}


install_containers () {
    # Container and Virtual Machine environments

    brew install compose2kube kubernetes-cli

    brew install xhyve

    brew install docker-compose 
    brew install docker-clean

    # Set permissions on xhyve properly
    brew --prefix | while read p; do
        sudo chown root:wheel $p/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
        sudo chmod u+s $p/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
    done

    # Docker's official release.
    # NOTE: This is preferred over several alternatives that leverage xhyve,
    # because the xhyve mode uses the 9p filesystem for mounted volumes/etc. 
    # This breaks when contained software requires manipulation of symbolic links.
    brew cask install docker

    brew cask install vagrant vagrant-manager
    brew cask install virtualbox virtualbox-extension-pack

}

install_cloudutils () {
    install_python_base
    brew cask install google-cloud-sdk
}

install_usermode () {
    # Various GUI utilities
    brew cask install \
        iterm2 fork github-desktop \
        cyberduck \
        macdown \
        transmission \
        veracrypt \
        caffeine
    brew install \
        terminal-notifier \
        gnupg \
        bfg \
        p7zip
}

install_nodejs () {
    brew install node phantomjs
}

install_webdev ()  {
    install_python_base
    brew cask install \
        postman
}

install_pythondev () {
    install_python_base
    brew install python3
}

install_database () {
    brew install \
        mysql mongodb postgresql
    brew cask install \
        mongohub mysqlworkbench robomongo \
        mongodbpreferencepane

    mkdir -p ~/Library/LaunchAgents
    cp `brew --prefix mysql`/*mysql*.plist ~/Library/LaunchAgents/
    launchctl load -w ~/Library/LaunchAgents/*mysql*.plist
}

install_golang () {
    brew install go
}

setup_git_osx_keychain () {

  git credential-osxkeychain get >/dev/null
  if [ $? -ne 1 -a $? -ne 0 ]; then
    curl -s -O http://github-media-downloads.s3.amazonaws.com/osx/git-credential-osxkeychain
    chmod u+x git-credential-osxkeychain
    sudo mv git-credential-osxkeychain $(dirname $(which git))/git-credential-osxkeychain
  fi

  git config --global credential.helper osxkeychain

}


main () {

    path="$1";
    mode="$2";

    case $mode in 
        prepare|restore|clean) return 0 ;;
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