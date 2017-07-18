#!/bin/sh


. ./setup-scripts/dotfiles.sh

filelist | while read dest orig; do
  printf "#--- %s\n#+++ %s\n" "$orig" "$dest"
  diff -Nau "${orig}" "${dest}"
done

