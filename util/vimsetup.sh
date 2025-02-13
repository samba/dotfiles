#!/usr/bin/env bash

set -euf -o pipefail


function gitclone () {
    local target_path="$1";
    local git_origin="$2";

    echo "Cloning ${git_origin} into ${target_path}" >&2

    if test -d "${target_path}" ; then
        cd "${target_path}";
        git pull --rebase;
        cd ${OLDPWD};
    else
        cd $(dirname "${target_path}");
        git clone "${git_origin}" $(basename "${target_path}");
        cd ${OLDPWD};
    fi

}

function do:vim:install_packaages () {
    echo "${HOME}/.vim/modules/pathogen" "https://github.com/tpope/vim-pathogen.git"
    echo "${HOME}/.vim/bundle/vim-json" "https://github.com/elzr/vim-json.git"
    echo "${HOME}/.vim/bundle/vim-openssl" "https://github.com/vim-scripts/openssl.vim.git"
    echo "${HOME}/.vim/bundle/vim-markdown" "https://github.com/tpope/vim-markdown.git"
    echo "${HOME}/.vim/bundle/vim-fugitive" "https://tpope.io/vim/fugitive.git"
    echo "${HOME}/.vim/bundle/vim-vinegar" "https://github.com/tpope/vim-vinegar.git"
    echo "${HOME}/.vim/bundle/jsbeautify" "https://github.com/vim-scripts/jsbeautify.git"
    echo "${HOME}/.vim/bundle/vim-ps1" "https://github.com/PProvost/vim-ps1.git"
    echo "${HOME}/.vim/bundle/vim-go" "https://github.com/fatih/vim-go.git"
}

function main () {
    local min=3 max=10
    mkdir -p ${HOME}/.vim/{backup,swap,modules,bundle,doc,autoload,syntax,plugin,ftdetect};
    ping -q -c 1 -W 1 google.com || echo -e "\n\n###_____ COULD NOT VERIFY INTERNET ACCESS  ____<<<<\n\n" >&2
    do:vim:install_packaages | shuf |  while read tgt src; do
        gitclone "${tgt}" "${src}" || return $?
        sleep $((RANDOM%($max-$min+1)+$min))
    done
    cd "${HOME}/.vim/autoload" && ln -sf ../modules/pathogen/autoload/pathogen.vim ./pathogen.vim;
}

main "$@"
