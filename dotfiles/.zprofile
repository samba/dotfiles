# Configuration loaded for login shells



if [ -x /usr/libexec/java_home ]; then
  export JAVA_HOME=`/usr/libexec/java_home -F 2>/dev/null`
fi

# Golang
export GOPATH=${HOME}/Projects/Go/

# Startup script for Python 3+
if command -v python 2>/dev/null >/dev/null; then
  export PYTHONSTARTUP=${HOME}/.pythonrc.py
  export PYTHON_USERCUSTOM=$(command python -c "import site; print(site.getusersitepackages())")
fi

if test "$(echo '::' | sed -E 's/:+/:/' 2>/dev/null)" = ":"; then
  export SED_REGEXP_VARIANT='-E'
else
  export SED_REGEXP_VARIANT='-R'
fi

if command -v pyenv >/dev/null; then
  eval "$(pyenv init -)"
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
  test -d "/opt/homebrew/bin" && echo /opt/homebrew/bin

  # If Go is installed custom
  test -d "/usr/local/go/bin" && echo /usr/local/go/bin


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



# Collect the paths that actually exist for $PATH
export PATH="$(__check_util_paths | tr -s '\n' ':'):${PATH}"

# Remove blanks from PATH
export PATH="${PATH/::/:}"



while read i; do
    test -d "$i" && export CDPATH="${CDPATH}:${i}"
done < <(__list_project_groups)


