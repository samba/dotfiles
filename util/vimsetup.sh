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
    gitclone "${HOME}/.vim/modules/pathogen" "https://github.com/tpope/vim-pathogen.git"
    gitclone "${HOME}/.vim/bundle/vim-json" "https://github.com/elzr/vim-json.git"
    gitclone "${HOME}/.vim/bundle/vim-openssl" "https://github.com/vim-scripts/openssl.vim.git"
    gitclone "${HOME}/.vim/bundle/vim-markdown" "https://github.com/tpope/vim-markdown.git"
	gitclone "${HOME}/.vim/bundle/jsbeautify" "https://github.com/vim-scripts/jsbeautify.git"
	gitclone "${HOME}/.vim/bundle/vim-ps1" "https://github.com/PProvost/vim-ps1.git"
	gitclone "${HOME}/.vim/bundle/vim-go" "https://github.com/fatih/vim-go.git"
}

function main () {
    mkdir -p ${HOME}/.vim/{backup,swap,modules,bundle,doc,autoload,syntax,plugin,ftdetect};
	ping -q -c 1 -W 1 google.com || echo -e "\n\n###_____ COULD NOT VERIFY INTERNET ACCESS  ____<<<<\n\n" >&2
	do:vim:install_packaages || return $?;
	cd "${HOME}/.vim/autoload" && ln -sf ../modules/pathogen/autoload/pathogen.vim ./pathogen.vim;
}

main "$@"
