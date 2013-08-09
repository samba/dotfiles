#!/bin/sh

DOWNLOADS=${HOME}/Downloads/Workspace
DOWNLOAD_IN_PROGRESS=0

download () {
  URL="$1" OUTFILE="$2"
  [ -z "$OUTFILE" ] && OUTFILE=`basename "$URL"`
  curl -k -C - -s -L "${URL}" -o "${DOWNLOADS}/$OUTFILE"
}

setup_git_osx_keychain () {

  git credential-osxkeychain >/dev/null
  if [ $? -ne 1 -a $? -ne 0 ]; then
    curl -s -O http://github-media-downloads.s3.amazonaws.com/osx/git-credential-osxkeychain
    chmod u+x git-credential-osxkeychain
    sudo mv git-credential-osxkeychain $(dirname $(which git))/git-credential-osxkeychain
  fi

  git config --global credential.helper osxkeychain

}


queue_downloads () {
  DOWNLOAD_IN_PROGRESS=1
  echo "# Downloading utilities to ${DOWNLOADS} (You will need to install these manually)">&2

  mkdir -p ${DOWNLOADS}
  download https://central.github.com/mac/latest GithubForMac.zip &
  download https://git-osx-installer.googlecode.com/files/git-1.8.2.2-intel-universal-snow-leopard.dmg &
  download https://macvim.googlecode.com/files/MacVim-snapshot-66-Lion.tbz &
  download https://iterm2.googlecode.com/files/iTerm2-1_0_0_20130319.zip iTerm2.zip &

  setup_git_osx_keychain

  # http://majutsushi.github.io/tagbar/
  # download http://github.com/majutsushi/tagbar/tarball/v2.5 vim-tagbar-2.5.tar.gz &
}



