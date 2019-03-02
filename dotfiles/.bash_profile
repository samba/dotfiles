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


function __check_util_paths () {
  # Produce a series of directories that usually have executables I'm interested in.

  echo ${HOME}/.bin
  echo ${HOME}/.dotfiles/bin

	# Homebrew will install some utilities here and there...
	# I need them early in my path.
  test -d "/usr/local/git/bin" && echo /usr/local/git/bin
  test -d "/usr/local/mysql/bin" && echo /usr/local/mysql/bin
  test -d "/usr/local/bin" && echo /usr/local/bin


  # PostgreSQL
  test -d /Applications/Postgres.app/ && \
    find /Applications/Postgres.app/ -type d -name bin
  
  # Sublime Text
  test -d /Applications/Sublime\ Text.app/ && \
    find /Applications/Sublime\ Text.app/ -type d -name bin

  # User's Python environment
  test -d ${HOME}/Library/Python/ && \
    find ${HOME}/Library/Python/ -type d -name bin

  test -d "${GOPATH}" && find "${GOPATH}" -maxdepth 3 -type d -name bin


  # Google AppEngine
  test -d /Applications/GoogleAppEngineLauncher.app/ && \
    find /Applications/GoogleAppEngineLauncher.app/ -type d -name google_appengine

}



function __login_includes () {

# Settings for specific homebrew contexts
if test -d /usr/local/Caskroom; then

    # Load PATH settings for google cloud & appengine
    echo "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"

fi

# If somehow GCloud is installed directly without homebrew
if test -d "${HOME}/Library/google-cloud-sdk"; then
    echo "${HOME}/Library/google-cloud-sdk/path.bash.inc"
fi
}




# Collect the paths that actually exist for $PATH
export PATH="$(__check_util_paths | tr -s '\n' ':'):${PATH}"

# Remove blanks from PATH
export PATH="${PATH/::/:}"


# Provide easier access to Go project paths 
test -d "${GOPATH}" && \
  export CDPATH=${CDPATH}:${GOPATH}/src/github.com:${GOPATH}/src/golang.org:${GOPATH}/src

export CDPATH="${CDPATH}:~/Projects/" 



while read i; do  # load the associated includes...
    test -f "$i" && source "$i"
done < <(__login_includes)


unset __check_util_paths __login_includes

# Import interactive shell configuration
if shopt -q login_shell || [[ $- == *i* ]]; then
  [ -f ~/.bashrc ] && source ~/.bashrc;
fi
