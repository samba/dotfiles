#!/bin/sh


. ./setup-scripts/dotfiles.sh

filelist | while read dest orig; do
  [ -f "${orig}" ] && cp -v ${orig} ./${dest} || echo "Missing ${orig}" >&2
done

