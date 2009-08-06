#!/bin/sh

b=$(dirname $0)
d=$(date +%s)

cd $HOME
mv .vimrc .vimrc-backup-$d
ln -s $b/vimrc .vimrc
cd $OLDPWD

