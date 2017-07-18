#!/usr/bin/env bash
# Configuration for login shells

if [ -x /usr/libexec/java_home ]; then
  export JAVA_HOME=`/usr/libexec/java_home -F 2>/dev/null`
fi


export GOPATH=${HOME}/Projects/Go/
export PATH=${PATH}:${GOPATH}/bin/



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

# Startup script for Python
export PYTHONSTARTUP=${HOME}/.pythonrc.py
export PYTHON_USERCUSTOM=`python -c "import site; print site.getusersitepackages()"`


# Import interactive shell configuration
if shopt -q login_shell; then
  [ -f ~/.bashrc ] && source ~/.bashrc;
fi
