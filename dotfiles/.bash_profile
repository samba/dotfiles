#!/usr/bin/env bash
# Configuration for login shells.
# This will be executed in subshells too.

# echo "Evaluating .bash_profile" >&2

if [ -x /usr/libexec/java_home ]; then
  export JAVA_HOME=`/usr/libexec/java_home -F 2>/dev/null`
fi

# Golang
export GOPATH=${HOME}/Projects/Go/

# Startup script for Python
export PYTHONSTARTUP=${HOME}/.pythonrc.py
export PYTHON_USERCUSTOM=`python -c "import site; print site.getusersitepackages()"`

# Ruby's gem environment
if test -d "${HOME}/.gem"; then
  export GEM_HOME="${HOME}/.gem"
  export GEM_PATH="${GEM_HOME}:${GEM_PATH}"
  export PATH="${HOME}/.gem/bin:${PATH}"
fi


if test "$(echo '::' | sed -E 's/:+/:/' 2>/dev/null)" = ":"; then
  export SED_REGEXP_VARIANT='-E'
else 
  export SED_REGEXP_VARIANT='-R'
fi


__check_util_paths () {
  # Produce a series of directories that usually have executables I'm interested in.

  echo ${HOME}/.bin
  echo ${HOME}/.dotfiles/bin

	# Homebrew will install some utilities here and there...
	# I need them early in my path.
  test -d "/usr/local/git/bin" && echo /usr/local/git/bin
  test -d "/usr/local/mysql/bin" && echo /usr/local/mysql/bin
  test -d "/usr/local/bin" && echo /usr/local/bin


  # Google AppEngine
  test -d /Applications/GoogleAppEngineLauncher.app/ && \
    find /Applications/GoogleAppEngineLauncher.app/ -type d -name google_appengine

  # PostgreSQL
  test -d /Applications/Postgres.app/ && \
    find /Applications/Postgres.app/ -type d -name bin
  
  # Sublime Text
  test -d /Applications/Sublime\ Text.app/ && \
    find /Applications/Sublime\ Text.app/ -type d -name bin

  # User's Python environment
  test -d ${HOME}/Library/Python/ && \
    find ${HOME}/Library/Python/ -type d -name bin

  # Hopefully a NodeJS environment was installed too.
  find /usr/local/ -type d -name 'node@*' -print0 | \
    xargs -0 -I {} find {} -name bin

  test -d "${GOPATH}" && find "${GOPATH}" -maxdepth 3 -type d -name bin
}


# Simplistic mode of populating cache data for faster startup.
# Usage:
#   bash::cachefile <name>  <populator function>
# 
# If the target file is not present, executes the given function to populate
# its content, and then prints the content. Future calls will load the reuse
# the file data directly.
bash::cachefile () {
  local target="${HOME}/.cache/bash/${1}"
  shift 1;
  if ! test -f "$target"; then
    mkdir -p "$(dirname "$target")"
    ${@} > "${target}"  # execute the func & prepare cache
  fi
  cat "${target}"
}



# Collect the paths that actually exist for $PATH
export PATH="$(bash::cachefile paths __check_util_paths | tr -s '\n' ':'):${PATH}"

# Remove blanks from PATH
export PATH="${PATH/::/:}"


unset __check_util_paths


# Import interactive shell configuration
if shopt -q login_shell; then
  [ -f ~/.bashrc ] && source ~/.bashrc;
fi
