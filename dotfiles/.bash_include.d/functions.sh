#!/bin/sh

gofind () {
    # Hopefully a simpler way to find things in important places...

    (test -d /go && echo /go
      test -d ${HOME}/go && echo ${HOME}/go
      test -d ${HOME}/Projects/ && echo $HOME/Projects/
      test -d ${HOME}/projects/ && echo $HOME/projects/
    ) | while read p; do 
        find $p "$@"; 
    done | egrep -v -e "(vendor|node_modules)/" \
            -e "\.?virt(ual)?env/"  | \
        sort -u
}

gd () { # shortcut for hopping into project directories
  foundpath="`gofind -type d -name "${@}" | head -n 1`"
  test -d "$foundpath" && pushd $foundpath
}


cdiff () {
  if which view >/dev/null; then
    diff -U 3 -wN "$@" | view -
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


docker_cleanup () {
  sudo -E docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs sudo -E docker rm
}

