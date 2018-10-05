#!/usr/bin/env bash



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


gd () { # shortcut for hopping into project directories
  local scan=$(test $# -gt 0  && echo "grep $@" || echo "cat")
  local foundpath=$(gofind | $scan | head -n 1)
  test -d ${foundpath} && pushd ${foundpath}
}



cdiff () {
  if which vim >/dev/null; then
    diff -U 3 -w -N $@ | vim -c 'set syntax=diff' -R -
  else
    diff -U 3 -wN "$@"
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
    help|-h|*) echo "Usage: crypto [en|de]crypt filename  # to stdout " >&2 ;;
  esac
}

myip () {
    ( # wrapped in a subshell so we can make it pretty. 
    # Query my own public IP address
    echo "public:" "$(dig +short myip.opendns.com @resolver1.opendns.com)"


    # Report my private IP address
    ifconfig -a | egrep -o '^[a-z0-9]+(?::)' | tr -d ':' | while read iface; do
        ipaddr=$(ipconfig getifaddr $iface)
        test -z "$ipaddr" || echo "$iface:" "$ipaddr"
    done 
    ) | column -t 
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