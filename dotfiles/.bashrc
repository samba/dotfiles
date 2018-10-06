#!/usr/bin/env bash
# Configuration for interactive (non-login) shells
# Settings applied here will not effect shells in embedded environments, e.g. VSCode
# !!NOTE: some functions herein used come from .bash_profile !!

export EDITOR=`which vim nano | head -n 1`

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

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
test -e "$HOME/.ssh/config"  && complete -o "default" -o "nospace" \
  -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" \
  scp sftp ssh;

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults;

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall;




__bash_files_import () {
  
  # Explicitly seeking these files is apparently faster than a dynamic search.
  test -f "/etc/bash_completion" && echo "/etc/bash_completion"

  test -f "${HOME}/.bash_functions" && echo "${HOME}/.bash_functions"
  test -f "${HOME}/.bash_colors" && echo "${HOME}/.bash_colors"
  test -f "${HOME}/.bash_prompt" && echo "${HOME}/.bash_prompt"
  test -f "${HOME}/.bash_sshagent" && echo "${HOME}/.bash_sshagent"
  test -f "${HOME}/.bash_aliases" && echo "${HOME}/.bash_aliases"
  test -f "${HOME}/.bash_completion" && echo "${HOME}/.bash_completion"

  # find /usr/local/Caskroom -type f -name '*.bash.inc'

  if test -d /usr/local/Caskroom; then
    for p in "path.bash.inc" "completion.bash.inc"; do
      echo "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/${p}"
    done
  fi

  # Google Cloud if installed via the web download (not Homebrew)
  if test -d "${HOME}/Library/google-cloud-sdk"; then
    for p in "path.bash.inc" "completion.bash.inc"; do
      echo "${HOME}/Library/google-cloud-sdkgoogle-cloud-sdk/${p}"
    done
  fi

  if test -d "/usr/local/opt/"; then
    # Homebrew links a bunch of scripts into this path.
    which brew >/dev/null && find $(brew --prefix)/etc/bash_completion.d/ -type l -maxdepth 1 
  fi

  

}


while read f; do
  test -f "$f" && source "$f"
done < <(__bash_files_import)


unset f
unset __bash_files_import
