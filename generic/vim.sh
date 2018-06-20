#!/usr/bin/env bash

internet_available () {
    ping -q -c 1 -W 1 google.com
}

update_git_path () {
  if [ -d "$2" ]; then
    pushd $2;
    git pull;
    popd
  else 
    git clone "$1" $2
  fi
 }

setup_vim () {

  # These paths are dictated by .vimrc as well
  mkdir -p ${1}/.vim/{backup,swap,doc}
  mkdir -p ${1}/.vim/{modules,autoload,bundle,syntax,plugin,ftdetect}

  
  update_git_path https://github.com/tpope/vim-pathogen.git ${1}/.vim/modules/pathogen
  
  pushd ${1}/.vim/autoload
  ln -s ../modules/pathogen/autoload/pathogen.vim ./pathogen.vim

  popd
  pushd ${1}/.vim/bundle
  
  internet_available && {

    update_git_path https://github.com/elzr/vim-json.git vim-json
    update_git_path https://github.com/vim-scripts/openssl.vim.git vim-openssl
    update_git_path https://github.com/tpope/vim-markdown.git vim-markdown

  }

  popd 
}

is_vim_setup_already () {
    test -d ${1}/.vim/backup || return 1
    test -d ${1}/.vim/swap || return 1
    test -d ${1}/.vim/modules || return 1
    test -d ${1}/.vim/bundle || return 1
    test -d ${1}/.vim/bundle/vim-json || return 1
    test -d ${1}/.vim/bundle/vim-openssl || return 1
    test -d ${1}/.vim/bundle/vim-markdown || return 1

    # finally
    return 0
}


main () {

    path="$1";
    mode="$2";


    case "$mode" in
        # All development contexts
        webdev|python|nodejs|golang|cloud|containers|dotfiles|all)
            is_vim_setup_already || setup_vim "$path"
        ;;
    esac
}

main "${@}"