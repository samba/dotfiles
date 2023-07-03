#!/usr/bin/env bash

set -euf -o pipefail

export PATH="${PATH}:/usr/local/bin:/opt/homebrew/bin"

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

    set -e  # exit immediately on failure

    sudo xcodebuild -checkFirstLaunchStatus
    [ $? -eq 69 ] || sudo xcodebuild -runFirstLaunch
    # sudo xcodebuild -license
    sudo xcode-select --install || true

    # Install homebroew
    set +x
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    set +e
    return 0
}

setup_homebrew_env () {
	(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"') >> ${HOME}/.zprofile
	(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv bash)"') >> ${HOME}/.bash_profile
    eval "$(/opt/homebrew/bin/brew shellenv $(basename ${SHELL}))"
}

brew::notify () {
   brew ${@} && return $?
   echo "!!! installation failed: brew $@" >&2
}

install_python_base () {
    which pip3 && return 0
    sudo easy_install pip3
    sudo -H pip3 install --upgrade --ignore-installed six python-dateutil
}


install_fonts () {
    # Powerline fonts
    requires brew || return $?
    brew search --casks "/font-.*-for-powerline/" 2>/dev/null | tail -n +2 | xargs -t brew install
}

autostart_mysql () {
    # Set up MySQL to launch automatically
    (find "$(brew --prefix mysql)" -type f -name '*.plist' || true) | while read f; do
        test -f "${f}" || continue
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
        install) # TODO: consider the roles ($2) in selecting which installations to run here.
            install_homebrew
			setup_homebrew_env
            install_python_base
            # install_fonts

            for role in ${2:-none}; do
                case $role in
                   productivity)  bash ${PWD}/util/install_rclone.sh ;;
                esac
            done

            ;;
        configure)
            eval "$(/opt/homebrew/bin/brew shellenv ${SHELL})"
            autostart_mysql
            setup_git_osx_keychain
            ;;
    esac

}


main "${@}"
exit $?
