#!/bin/bash

set -euf -o pipefail

# This is my default signing key. You probably want to change it.
# If your git config also provides a signing key ID, it will 
# take precedence, and this setting will have no effect..
export GIT_SIGNING_KEY="7ACE561D"


function setup_whitespace () {
  git config -f $1 apply.whitespace nowarn
  git config -f $1 core.whitespace "fix,-indent-with-non-tab,trailing-space,cr-at-eol.space-before-tab"
}

function setup_colors () {
  # From `git config --help`
  # The basic colors accepted are normal, black, red, green, yellow, blue, magenta, cyan and white. 
  # The first color given is the foreground; the second is the background.
  # Colors may also be specified as numbers 0 through 255, or #aabbcc for 24-bit terminals.

  git config -f $1 color.ui auto

  git config -f $1 color.diff.meta "cyan bold"
  git config -f $1 color.diff.frag "magenta bold"
  git config -f $1 color.diff.old "red bold"
  git config -f $1 color.diff.new "green bold"
  git config -f $1 color.diff.whitespace "red reverse"

  git config -f $1 color.status.added "green"
  git config -f $1 color.status.changed "yellow"
  git config -f $1 color.status.untracked "red"
  git config -f $1 color.status.updated "magenta"
  git config -f $1 color.status.branch "green"

  git config -f $1 color.branch.current "yellow reverse"
  git config -f $1 color.branch.local "yellow"
  git config -f $1 color.branch.remote "green"
}

function setup_tools () {
  local current_signing_key="$(git config -f $1 --get user.signingkey)"
  local current_signing_active="$(git config -f $1 --get commit.gpgsign)"
  git config -f $1 core.editor vim
  git config -f $1 merge.tool vimdiff
  git config -f $1 credential.helper osxkeychain
  git config -f $1 gpg.program "gpg"
  git config -f $1 user.signingkey "${current_signing_key:-${GIT_SIGNING_KEY}}"
  
  # Explicitly disable signing commits, unless the user already has it active.
  git config -f $1 commit.gpgsign ${current_signing_active:-false}
}

function setup_proto () {
  # always push via SSH - works with credential.helper above.
  git config -f $1 url.git\@github\.com\:.pushInsteadOf https://github.com/
}

function setup_log (){
  git config -f $1 log.date short
}


function setup_gitworkflow () {
  # Detect copies as well as renames
  git config -f $1 diff.renames copies

  # Automatically correct command typos
  git config -f $1 help.autocorrect 1

  # Older versions need push method `matching`
  git config -f $1 push.default simple
}

function setup_alias () {

  # Status shortcuts
  git config -f $1 alias.st "status -sb"
  git config -f $1 alias.s "status --short --branch --ignore-submodules=untracked"

  # Branching shortcuts
  git config -f $1 alias.br "branch"
  git config -f $1 alias.op "checkout --orphan"
  git config -f $1 alias.co "checkout"

  # Pull/fetch shortcuts
  git config -f $1 alias.pr "pull --rebase"
  git config -f $1 alias.fs "!git fetch --all && git status -sb && git diff --stat"

  # Various commit shortcuts
  git config -f $1 alias.ci "commit -a"
  git config -f $1 alias.amend "commit --amend --no-edit"

  # Various diff shortcuts
  git config -f $1 alias.dl "!git diff --color | less -R"
  git config -f $1 alias.dc "diff --cached --diff-filter=AMCR"
  git config -f $1 alias.di "diff --diff-filter=AMCR"
  git config -f $1 alias.da "diff --abbrev --minimal -M -C -D -b"
  git config -f $1 alias.df "diff --stat"
  
  # Logging with all the right details.
  git config -f $1 alias.lo "log --graph --oneline"
  git config -f $1 alias.lp "log -p"
  git config -f $1 alias.l "log --graph --oneline --format='format:%C(green)% h%C(reset)% s%C(magenta)% ad%C(reset)%C(cyan)% d%C(reset)%C(yellow)% ae%C(reset)'"

  # log with full dates; relies on the logging alias above
  git config -f $1 alias.hist "!git l --date=iso"

  # List aliases
  git config -f $1 alias.alias "!git config -l | grep alias | cut -c 7- | sort | awk 'BEGIN {FS = \"=\"}; {printf \"\033[36m%-10s\033[0m %s\n\", \$1, \$2}'"

  git config -f $1 alias.showfiles "show --stat"
}

function main () {
  setup_gitworkflow $1
  setup_proto $1
  setup_whitespace $1
  setup_colors $1
  setup_tools $1
  setup_log $1
  setup_alias $1
}

main "$@"