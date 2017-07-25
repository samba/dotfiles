#!/usr/bin/env bash
# Configuration for login shells

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

__check_util_paths () {
  # Produce a series of directories that usually have executables I'm interested in.

  echo ${HOME}/.bin
  echo ${HOME}/.dotfiles/bin

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

  echo /usr/local/git/bin
  echo /usr/local/mysql/bin
  echo /usr/local/bin

}


__actually_dirs () {
  while read i; do
    test -d "$i" && echo "$i"
  done
}

# Collect the paths that actually exist for $PATH
export PATH="$(__check_util_paths | __actually_dirs | tr -s '\n' ':'):${PATH}"





# Import interactive shell configuration
if shopt -q login_shell; then
  [ -f ~/.bashrc ] && source ~/.bashrc;
fi
