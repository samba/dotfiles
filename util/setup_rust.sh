#!/bin/bash


command -v rustup-init  && rustup-init -yq

test -f ~/.cargo/env && source ~/.cargo/env

cargo install cargo-wasi