#!/bin/bash

set -euf -o pipefail

mkdir -p ~/.tmux/plugins ~/.tmux/resurrect

if [ -d ~/.tmux/plugins/tpm ]; then
    git -C ~/.tmux/plugins/tpm pull --quiet
else
    git clone --quiet https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi



grep 'plugins/tpm' ~/.tmux.conf && ${SHELL} ~/.tmux/plugins/tpm/scripts/install_plugins.sh
