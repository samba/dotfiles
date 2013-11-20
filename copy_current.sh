#!/bin/sh


. ./installation-scripts/dotfiles.sh

filelist | while read dest orig; do
  [ -f "${orig}" ] && cp -v ${orig} ./${dest}
done

