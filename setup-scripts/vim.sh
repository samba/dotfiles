#!/bin/sh


vim_clean_home_filepath () {
  sed "s@dotfiles/vim/(.*)@& ${HOME}/.vim/\1@"
}

filelist_vim () {
  echo dotfiles/vimrc ~/.vimrc
  find dotfiles/vim/ -type f | vim_clean_home_filepath
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

  mkdir -p ~/.vim/{backup,swap,doc}
  mkdir -p ~/.vim/{modules,autoload,bundle,syntax,plugin,ftdetect}

  cp -v dotfiles/vimrc ${HOME}/.vimrc
  
  update_git_path https://github.com/tpope/vim-pathogen.git ~/.vim/modules/pathogen
  
  pushd ~/.vim/autoload
  ln -s ../modules/pathogen/autoload/pathogen.vim ./pathogen.vim

  popd
  pushd ~/.vim/bundle
  
  
  update_git_path https://github.com/elzr/vim-json.git vim-json
  update_git_path https://github.com/vim-scripts/openssl.vim.git vim-openssl
  update_git_path https://github.com/tpope/vim-markdown.git vim-markdown

  popd 
}



