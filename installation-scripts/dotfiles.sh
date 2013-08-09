#!/bin/sh


DATE=`date +%Y%m%d_%H%M%S`
ARCHIVE_OUT=/tmp/workspace-archive-${DATE}.tar.gz

filelist () {
cat <<EOF
dotfiles/gitconfig    ${HOME}/.gitconfig
dotfiles/vimrc        ${HOME}/.vimrc
dotfiles/bash_aliases ${HOME}/.bash_aliases
dotfiles/bash_profile ${HOME}/.bash_profile
dotfiles/bashrc       ${HOME}/.bashrc
dotfiles/screenrc     ${HOME}/.screenrc
EOF
}

makedirs () {
  mkdir -p ${HOME}/.vim/{backup,swap,autoload,syntax,doc,plugin}
  mkdir -p ${HOME}/Projects
}



setup_dotfiles () {
  echo "# Preparing directories" >&2
  makedirs;

  if [ ! -f "${HOME}/.ssh/id_rsa" ]; then
    echo "# Preparing SSH key files (enter passphrase; empty is OK)" >&2
    ssh-keygen -b 2048 -f "${HOME}/.ssh/id_rsa"
  fi

  echo "# Copying configuration files; archiving original in ${ARCHIVE_OUT}" >&2
  filelist | awk '{print $2}' | xargs tar -czvf ${ARCHIVE_OUT}
  filelist | while read origin dest; do
    [ -f "${origin}" ] && cp -v "${origin}" "${dest}"
  done

}

