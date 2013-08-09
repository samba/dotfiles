#!/bin/sh

DOWNLOADS=${HOME}/Downloads/Workspace
DOWNLOAD_IN_PROGRESS=0

download () {
  URL="$1" OUTFILE="$2"
  [ -z "$OUTFILE" ] && OUTFILE=`basename "$URL"`
  curl -k -C - -s -L "${URL}" -o "${DOWNLOADS}/$OUTFILE"
}


queue_downloads () {
  DOWNLOAD_IN_PROGRESS=1
  echo "# Downloading utilities to ${DOWNLOADS} (You will need to install these manually)">&2

  mkdir -p ${DOWNLOADS}
  download https://central.github.com/mac/latest GithubForMac.zip &
  download https://git-osx-installer.googlecode.com/files/git-1.8.2.2-intel-universal-snow-leopard.dmg &
  download https://macvim.googlecode.com/files/MacVim-snapshot-66-Lion.tbz &
  download https://iterm2.googlecode.com/files/iTerm2-1_0_0_20130319.zip iTerm2.zip &

  # http://majutsushi.github.io/tagbar/
  # download http://github.com/majutsushi/tagbar/tarball/v2.5 vim-tagbar-2.5.tar.gz &
}



