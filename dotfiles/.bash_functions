#!/usr/bin/env bash


function http () {
  # usage: http POST "http://example.com/uri" "{\"test\":true}"
  # Provides a uniform shortcut for issuing HTTP requests.
  local verb=$1; shift;
  local URL=$1; shift;
  local body=${1:-""}; shift;

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
