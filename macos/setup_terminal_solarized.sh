#!/bin/bash

urldecode() {
    : "${*//+/ }"; 
    echo -e "${_//%/\\x}"; 
}

download_config () {
    url="https://raw.githubusercontent.com/tomislav/osx-terminal.app-colors-solarized/master/Solarized%20${1}.terminal"
    output="$(urldecode "$(basename "${url}")")"
    wget -qL "${url}" -O "${output}"
    echo "$output"
}


case $1 in
    Light|Dark)  open "$(download_config $1)";;
esac
