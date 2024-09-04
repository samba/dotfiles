#!/bin/bash

set -euf -o pipefail

# Install OhMyZSH
# NB: (XXX) this overwrites the versioned .zshrc, so below it gets sourced with a custom name...
# NB: in debug mode this is extremely noisy.
${SHELL} -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended


OMZSH=~/.oh-my-zsh
CUSTOM=${OMZSH}/custom

mkdir -p ${OMZSH} ${CUSTOM}

PLUGIN_REPOS=(
    "https://github.com/zsh-users/zsh-autosuggestions"
    "https://github.com/zsh-users/zsh-syntax-highlighting"
    "https://github.com/zdharma-continuum/fast-syntax-highlighting"
)


for k in "${PLUGIN_REPOS[@]}"; do
    b=$(basename "${k}")
    if [ -d ${CUSTOM}/plugins/${b} ]; then
        git -C ${CUSTOM}/plugins/${b} pull --quiet
    else
        git clone --quiet --filter=blob:none "${k}" ${CUSTOM}/plugins/${b}
    fi
done

grep  "source ~/.zshrc.${USER}" ~/.zshrc || echo -e "\n\nsource ~/.zshrc.${USER}" >> ~/.zshrc

test -f ~/.zshrc.pre-oh-my-zsh \
    && test  ~/.zshrc -nt ~/.zshrc.pre-oh-my-zsh \
    && mv -v ~/.zshrc.pre-oh-my-zsh ~/.zshrc.${USER}
