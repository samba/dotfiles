#!/bin/sh

report_err () {
  local err=$1 step=$2 rpt=$3
  echo "$step failed, return = $err"
  sed 's/^/\t> /' $rpt
}

git_sync () {
  local r=0
  cd $1;
  git fetch -q -t -a && git push --all
  r=$?
  cd $OLDPWD
  return $r
}


git_sync_recursive () {
  find $1/ -type d -name .git -exec dirname {} \; | while read l; do
    echo ">>> $l" >&2
    echo $l > $2
    git_sync $l 1>>$2 2>>$2 || report_err $? $l $2
  done
}

main () {
  local has_run=n errfile=$(mktemp /tmp/err.XXXX)
  while getopts :d: Opt; do
    case $Opt in
      d) git_sync_recursive $OPTARG $errfile; has_run=y;;
    esac
  done
  [ $has_run = 'n' ] && git_sync_recursive ./ $errfile
  rm $errfile
}


main $@
