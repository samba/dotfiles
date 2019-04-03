#!/usr/bin/env bash


function http () {
  # usage: http POST "http://example.com/uri" "{\"test\":true}"
  # Provides a uniform shortcut for issuing HTTP requests.

  local helptext="usage: http {GET|PUT|POST|DELETE...} http://example.com/url  \"{json...}\""

  local verb="${1:-NONE}"
  local URL="${2:-NONE}"
  local body="${3:-""}"

  case "${verb}" in
    -h|--help|help|NONE)
        echo "${helptext}" >&2
        return 1
    ;;
  esac

  while read prgm; do
    case "$(basename ${prgm})" in
      curl)
        ${prgm} -s -X ${verb} --data "${body}" -o - "${URL}"
      ;;
      wget)
        ${prgm} --method="${verb}" --body-data "${body}" -O - "${URL}"
      ;;
    esac
  done < <(which -a curl wget | head -n 1)

}

function myip () {
  if which dig >/dev/null ; then
    echo "public:" "$(dig +short myip.opendns.com @resolver1.opendns.com)"
  else
    echo "public:" "$(http GET "https://api.ipify.org")"
  fi

  case $(uname -s) in
    Darwin)

      if which ifconfig >/dev/null && which ipconfig >/dev/null ; then
        while read iface; do
          local ipaddr=$(ipconfig getifaddr ${iface})
          test -z "${ipaddr}" || echo "${iface}: ${ipaddr}"
        done < <(ifconfig -a | egrep -o '^[a-z0-9]+(?::)' | tr -d ':')
      fi
  esac


}

function __gopath_base () {
    # NB. on MacOS we cannot rely on `go env GOROOT`, because homebrew sets up the
    # path /usr/local/Cellar/<version>/libexec, which is NOT where we want to checkout
    # development code...
    (   echo "$GOPATH" | tr -s ':' '\n';
        test -z "$GOROOT" || echo "$GOROOT";
        echo "${HOME}/go"
    ) | while read i; do
        test -d "$i" && echo "$i" && return 0
    done
}

function gitgo() {
    local rpath="$1"; shift;
    local repo_orig="$(echo ${rpath} | sed 's%^github.com/%git@github.com:%')"
    local gopath="$(__gopath_base | head -n 1)"
    test -d "${gopath}/src" || return $?

    # validate rpath format (like <host.com>/<org>/<repo> for go origins)
    echo "${rpath}" | grep -E -q -e '^([a-z0-9]+\.)+[a-z]{2,4}/[a-z0-9]' || return $?

    local tpath="${gopath}/src/${rpath}";

    if test -d "${tpath}"; then
        echo "Fetching updated ${rpath}..." >&2
        cd "$tpath" && git fetch --all;
    else
        echo "Cloning ${rpath}..." >&2
        git clone "${repo_orig}" "${tpath}" && cd "$tpath"
    fi
}


gofind () {
  # Paths to search
  (
    test -d /go && echo "/go"
    test -z "$GOPATH" || (echo "${GOPATH/:/\\n}" | sed 's@$@/src@')
    test -d ~/Projects && echo "${HOME}/Projects"
  ) | sed 's@//@/@' | xargs -I {} find -L {} -type d -name '*.git' \
    | egrep -v -e "/(vendor|node_modules|dep|.*cache.*)/?" \
    | sed 's@/.git$@@' \
    | sort -u

}


function gd () { # shortcut for hopping into project directories
  local scan=$(test $# -gt 0  && echo "grep $@" || echo "cat")
  local foundpath=$(gofind | $scan | head -n 1)
  test -d ${foundpath} && pushd ${foundpath}
}



function cdiff () { # color diff via vim, whee!
  if which vim >/dev/null; then
    $(which diff) -U 3 -w -N $@ | vim -c 'set syntax=diff' -R -
  else
    $(which diff) -U 3 -wN "$@"
  fi
}

function cview () {
  local ft="$1"; shift;
  if test $# -eq 0; then
    vim -R -c "set ft=${ft}" -
  else
    vim -R -c "set ft=${ft}" "$@"
  fi
}

remove_path_exec() {
    local sarg="${SED_REGEXP_VARIANT:--R}"
    for ex; do
        pexec="$(dirname $(which ${ex}))"
        export PATH="$(echo "$PATH" | sed $sarg "s@(:${pexec}|${pexec}:|^${pexec}$)@@")"
    done
}



seldir () {
  [ $# -gt 0 ] && dirs -v | egrep "$@" || dirs -
  read -p "Directory number: " dirnum
  [ -z "$dirnum" ] || pushd +${dirnum} >/dev/null 2>/dev/null
  echo "#" `pwd`
}

crypto () {
  case $1 in
    encrypt) openssl aes-256-cbc -e -in "${2}" -out -;;
    decrypt) openssl aes-256-cbc -d -in "${2}" -out -;;
    help|-h|*) echo "Usage: crypto {encrypt|decrypt} filename  # to stdout " >&2 ;;
  esac
}


ssh_fingerprints () {
  find ${HOME}/.ssh -name '*rsa' | while read f; do
    echo `ssh-keygen -E md5  -lf ${f}` "($f)"
  done
}

docker_cleanup () {
  sudo -E docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs sudo -E docker rm
  sudo -E docker image prune
  sudo -E docker system prune
}


macdown() {  # Application shortcut
    "$(mdfind kMDItemCFBundleIdentifier=com.uranusjr.macdown | head -n1)/Contents/SharedSupport/bin/macdown" $@
}


# Simple calculator
# copied from https://github.com/jessfraz/dotfiles/blob/master/.functions

function calc() {
  local result=""
  result="$(printf "scale=10;%s\\n" "$*" | bc --mathlib | tr -d '\\\n')"
  #            └─ default (when `--mathlib` is used) is 20

  if [[ "$result" == *.* ]]; then
    # improve the output for decimal numbers
    # add "0" for cases like ".5"
    # add "0" for cases like "-.5"
    # remove trailing zeros
    printf "%s" "$result" |
      sed -e 's/^\./0./'  \
      -e 's/^-\./-0./' \
      -e 's/0*$//;s/\.$//'
  else
    printf "%s" "$result"
  fi
  printf "\\n"
}



