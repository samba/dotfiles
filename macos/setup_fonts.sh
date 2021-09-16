#!/usr/bin/env bash

set -euf -o pipefail

brew install svn # because some of these fonts get pulled from SVN sources (:facepalm:)
brew search '/font-(inconsolata|consolas|poppins|sourcecode|ubuntu|droid|merriweather)/' | grep -v '==' | grep -v -e powerline -e lgc | xargs brew install
