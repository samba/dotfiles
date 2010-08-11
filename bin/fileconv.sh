#!/bin/sh

main () {
  local use_stdout=no output_fmt= output_arg=
  while getopts :DUo Opt; do
    case $Opt in
      o) use_stdout=yes;;
      D) output_fmt=dos;;
      U) output_fmt=unix;;
    esac
  done

  shift $(( $OPTIND -1 ))

  case $use_stdout in
    yes) output_arg='' ;;
    no) output_arg='-i' ;;
  esac

  for workfile; do
    case $output_fmt in
      dos)
        sed -e 's/$/\r/' $output_arg $workfile
        ;;
      unix)
        sed -e 's/\r$//' $output_arg $workfile
        ;;
     esac
  done

}

main $@
