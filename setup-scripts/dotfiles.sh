#!/bin/sh


DATE=`date +%Y%m%d_%H%M%S`
ARCHIVE_OUT=/tmp/workspace-archive-${DATE}.tar.gz

PYTHON_USERCUSTOM=`python -s -c "import site; print site.getusersitepackages()"`

filelist () {
cat <<EOF
dotfiles/gitconfig    ${HOME}/.gitconfig
dotfiles/bash_aliases ${HOME}/.bash_aliases
dotfiles/bash_profile ${HOME}/.bash_profile
dotfiles/bashrc       ${HOME}/.bashrc
dotfiles/screenrc     ${HOME}/.screenrc
dotfiles/pythonrc.py  ${HOME}/.pythonrc.py
dotfiles/usercustomize.py ${PYTHON_USERCUSTOM}/usercustomize.py
dotfiles/psqlrc       ${HOME}/.psqlrc  
utils/sshtunnel       ${HOME}/.dotfiles/bin/sshtunnel
EOF
}

makedirs () {
  mkdir -p ${HOME}/.dotfiles/bin
  mkdir -p ${HOME}/Projects
  mkdir -p ${PYTHON_USERCUSTOM}
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
    mkdir -p "`dirname "${dest}"`"
    [ -f "${origin}" ] && cp -v "${origin}" "${dest}"
  done

  find ${HOME}/.dotfiles/bin/ -type f -print0 | xargs -0 chmod 0700 
}

