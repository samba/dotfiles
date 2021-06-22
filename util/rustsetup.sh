#!/bin/bash


command -v rustup-init  && rustup-init -yq

test -f ~/.cargo/env && source ~/.cargo/env

command -v cargo && cargo install cargo-wasi