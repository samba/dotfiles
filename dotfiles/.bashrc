#!/usr/bin/env bash
# Configuration for interactive (non-login) shells
# Settings applied here will not effect shells in embedded environments, e.g. VSCode

echo "Running .bashrc ($SECONDS)" >&2

export EDITOR=$(which vim nano | head -n 1)

# Configure history backlog
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE=history:jobs:fg:bg
export HISTSIZE=32768
export HISTFILESIZE="${HISTSIZE}";
export HISTTIMEFORMAT='%F %T '

# Prefer US English and use UTF-8.
export LANG='en_US.UTF-8';
export LC_ALL='en_US.UTF-8';

export PAGER=less
export LESS='-iMSx4 -FXR'

# Don’t clear the screen after quitting a manual page.
export MANPAGER='less -X';

# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\e[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\e[01;38;5;74m'  # begin bold (section title)
export LESS_TERMCAP_me=$'\e[0m'           # end mode
export LESS_TERMCAP_se=$'\e[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\e[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\e[0m'           # end underline
export LESS_TERMCAP_us=$'\e[04;38;5;146m' # begin underline

# Avoid issues with `gpg` as installed via Homebrew.
# https://stackoverflow.com/a/42265848/96656
export GPG_TTY=$(tty);

# Update window size $LINES and $COLUMNS after each command
shopt -s checkwinsize

# Perform hostname completion when a word completion follows "@"
shopt -s hostcomplete

# Rescans $PATH when a given command/executable from the hash goes missing...
shopt -s checkhash;

# Try not to exit before background jobs are done...
shopt -s checkjobs 2>/dev/null

# Warn when there's mail pending.
# shopt -s mailwarn;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Attempt word expansion when performing filename completion
shopt -s direxpand 2>/dev/null

# Attempt to fix spelling errors in directory word expansion
shopt -s dirspell 2>/dev/null

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Try to retain multi-line commands as single entry in history
shopt -s cmdhist;

# Allow user to edit a failed history substitution
shopt -s histreedit;


__bash_files_import () {

  # Google Cloud completion
  echo "${GCLOUD_ROOT}/completion.bash.inc"

  if command -v brew >/dev/null; then
    echo $(brew --prefix)/etc/bash_completion
  fi

  echo "/etc/bash_completion"
  echo "${HOME}/.bash_completion"
  echo "${HOME}/.bash_functions"
  echo "${HOME}/.bash_aliases"
  echo "${HOME}/.bash_colors"
  echo "${HOME}/.bash_prompt"
  echo "${HOME}/.bash_sshagent"
  echo "${HOME}/.bash_gpgagent"
  echo "${HOME}/.bashrc_local"

}


while read f; do
  test -f "$f" && source "$f"
done < <(__bash_files_import)




unset f
unset __bash_files_import


echo "Finished .bashrc ($SECONDS)" >&2