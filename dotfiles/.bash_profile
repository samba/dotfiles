#!/usr/bin/env bash
# Configuration for interactive login shells, or non-interactive with --login flag.
# This will be executed in subshells too.

if [ -x /usr/libexec/java_home ]; then
  export JAVA_HOME=`/usr/libexec/java_home -F 2>/dev/null`
fi

# Golang
export GOPATH=${HOME}/Projects/Go/

# Startup script for Python
export PYTHONSTARTUP=${HOME}/.pythonrc.py
export PYTHON_USERCUSTOM=$(python -c "import site; print site.getusersitepackages()")

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

if command -v pyenv >/dev/null; then
  eval "$(pyenv init -)"
fi

if command -v gcloud >/dev/null; then
  export GCLOUD_ROOT=$(gcloud info --format="value(installation.sdk_root)")
  export GOOGLE_APPENGINE_PATH="${GCLOUD_ROOT}/platform/google_appengine/"
fi


function __check_util_paths () {
  # Produce a series of directories that usually have executables I'm interested in.

  echo ${HOME}/.bin
  echo ${HOME}/.dotfiles/bin
  echo "${HOME}/.local/bin"

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

}



function __login_includes () {

  # GCloud can be installed in several locations, but we infer it from the available execution
  test -d "${GCLOUD_ROOT}" && echo "${GCLOUD_ROOT}/path.bash.inc"

}


# Collect the paths that actually exist for $PATH
export PATH="$(__check_util_paths | tr -s '\n' ':'):${PATH}"

# Remove blanks from PATH
export PATH="${PATH/::/:}"


function __list_project_groups () {
    echo "${HOME}/Projects/"
    echo "${HOME}/Projects/Personal/"
    echo "${HOME}/Projects/Datacraft/"
    echo "${HOME}/Projects/Mycelial/"

    # Provide easier access to Go project paths
    echo "${GOPATH}/src/github.com"
    echo "${GOPATH}/src/golang.org"
    echo "${GOPATH}/src"
}


while read i; do
    test -d "$i" && export CDPATH="${CDPATH}:${i}"
done < <(__list_project_groups)



while read i; do  # load the associated includes...
    test -f "$i" && source "$i" || echo 'missing?' $i >&2
done < <(__login_includes)

unset __check_util_paths __login_includes  __list_project_groups



test -f "$HOME/.cargo/env" && source "$HOME/.cargo/env"


# Load runtime config for interactive terminals
case "$-" in
    *i*) source ~/.bashrc ;;
esac

# Terminal behavior on MacOS is a little weird.
# case $(uname -s) in
#     Darwin)
#         shopt -q login_shell && \
#             test -z "$PS1" && \
#             source ~/.bashrc;;
# esac



