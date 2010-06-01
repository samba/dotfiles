
# Replaces whitespace from filenames with underline
# Usage: [file] ...
function f.stripws () {
  while [ $# -gt 0 ]; do 
    mv $1 $(echo $1 | tr \  _)
    shift
  done
}

# Sanitize a filename
function f.sanitize () {
  while [ $# -gt 0 ]; do
    clean=${1// /_}
    clean=${clean//[^a-zA-Z0-9_.-]/}
    mv $1 $clean
  done
}
function f.tolower() { 
  while [ $# -gt 0 ]; do 
    mv $1 $(echo $1 | tr A-Z a-z) 
    shift
  done
}

function dua() { IFS=$'\n'; for i in `ls -1`; do du "$i"; done; }
function duaa() { IFS=$'\n'; for i in `ls -A1`; do du "$i"; done; }

function duanew() { 
  du `ls` | awk '{col="\033[01;32m"};$1~/(M|G)/&&int($1)>10{col="\033[01;31m"};{print col $0}'
}

function mkcd() { 
  mkdir $1 && cd $1
}

function mknow() { 
  dirname=$(date +%Y%m%d)
  [ -n "$@" ] && dirname=${dirname}
  mkdir $dirname
}


# Set permissions of all directories recursively to $1
function d.chmodr() { find . -type d -exec chmod $1 {} \; ; }

# Set permissions of all files recursively to $1
function f.chmodr() { find . -type f -exec chmod $1 {} \; ; }
