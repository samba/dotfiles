#!/bin/bash


if command -v rustup-init; then

    rustup-init -yq

    test -f ~/.cargo/env && source ~/.cargo/env

    command -v cargo && cargo install cargo-wasi

fi

