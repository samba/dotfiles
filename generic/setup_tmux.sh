#!/bin/bash

set -euf -o pipefail

mkdir -p ~/.tmux/plugins ~/.tmux/resurrect

if [ -d ~/.tmux/plugins/tpm ]; then
    git -C ~/.tmux/plugins/tpm pull --quiet
else
    git clone --quiet https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# NB: tmux setup is bash script, not functional with zsh...
grep 'plugins/tpm' ~/.tmux.conf && bash ~/.tmux/plugins/tpm/scripts/install_plugins.sh
