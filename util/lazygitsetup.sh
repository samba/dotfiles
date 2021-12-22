#!/bin/bash


export VER="0.31.4"
export OUTFILE=$(mktemp /tmp/lazygit.tar.gz.XXXXXX)


wget -O $OUTFILE https://github.com/jesseduffield/lazygit/releases/download/v${VER}/lazygit_${VER}_Linux_x86_64.tar.gz

sudo tar xvf $OUTFILE -C /usr/local/bin/ lazygit
sudo chmod +x /usr/local/bin/lazygit
sudo chown root:users /usr/local/bin/lazygit
rm $OUTFILE
