#!/bin/sh

o=$(dirname $(readlink -f $0));
d=$(date +%Y-%m-%d-%H:%M:%S)

cd ${HOME}


mv .bashrc .bashrc.backup-$d
ln -s $o/bashrc.sh .bashrc

mv .bash_logout .bash_logout.backup-$d
ln -s $o/logout.sh .bash_logout

mv .bash_aliases .bash_aliases.backup-$d
ln -s $o/aliases .bash_aliases

mv .screenrc .screenrc.backup-$d
ln -s $o/screenrc .screenrc

cd $OLDPWD;
