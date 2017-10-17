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

install_nodejs () {
    requires npm "Please install NPM." || return $?
    npm install --upgrade -g \
        growl \
        {babel,gulp,grunt}-cli \
        gyp \
        nyc istanbul \
        jshint eslint \
        mocha \
        node-sass \
        google-closure-compiler-js
}

install_cloudutils () {
    require_sudo || return $?
    sudo -H pip install google-api-python-client awscli awslogs
}

install_webdev () {
    require_sudo || return $?
    sudo -H pip install lesscpy flask
}



install_golang () {
    export GOPATH=${HOME}/Projects/Go/
    mkdir -p ${HOME}/Projects/Go/{src,bin,pkg}

    go get -u github.com/golang/lint/golint
    go get honnef.co/go/simple/cmd/gosimple
    go get golang.org/x/tools/cmd/goimports
}

main () {

    path="$1";
    mode="$2";

    case $mode in
        prepare|restore|clean) return 0 ;;
        downloads) return 0 ;;
    esac


    case "$mode" in
        cloud) install_cloudutils ;;
        golang) install_golang ;;
        webdev) 
            install_nodejs
            install_webdev
        ;;
        nodejs) install_nodejs ;;
        all)
            install_nodejs
            install_golang
            install_webdev
            install_cloudutils
        ;;
    esac
}


main "${@}"
exit $?
