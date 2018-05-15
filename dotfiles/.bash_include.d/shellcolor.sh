#!/usr/bin/env bash

export FORCEFUL="${FORCEFUL:-0}"


requires(){ # simple wrapper to check presence of executables.
  which $@ >/dev/null
}

forceful() {
  [ "${FORCEFUL:-0}" -eq 1 ] && echo "$@"
}


print_available_colors () {
  for C in {0..255}; do
    tput setaf $C
    echo -n "$C "
  done
  tput sgr0
  echo
}


# This function prepares strings with color- and style-oriented control codes.
# Commands are usually formatted as:
#   <style> <color> <bg|fg> "<text content>"
# 
# Examples:
#   generate_color_terms red fg "test"           (makes red text)
#   generate_color_terms red intense bg "test"   (makes red background intense)
#   ... red underline fg intense blue bg "test" 
#
# Control codes are only issued by three terms:
#  - bg  (sets preceding color detail to background)
#  - fg  (sets preceding color detail to foreground text)
#  - reset  (clears existing flags)
# 
# When a control code is issued by one of these commands, its effects apply to
# the subsequent text.
# 
# Some rich bash-isms here. 
generate_color_terms () {
  local IFS=";"
  local -i color=0
  local -a flags
  local -i intense=0  # (when intense=60, colors are... intense.)
  flags[0]=0 # no style to start. (initialize array)
  for i; do
    case "$i" in
      default)
        flags[${#flags[@]}]=0  # add a reset flag.
        let intense=0 
        let color=0
      ;;
      blink) flags[${#flags[@]}]=5;;
      underline) flags[${#flags[@]}]=4;;
      dim) flags[${#flags[@]}]=2;;
      bold) flags[${#flags[@]}]=1;;
      intense) let intense=60;;
      black) color=$((intense + 30));;
      red) color=$((intense + 31));;
      green) color=$((intense + 32));;
      yellow) color=$((intense + 33));;
      blue) color=$((intense + 34));;
      purple) color=$((intense + 35));;
      cyan) color=$((intense + 36));;
      white) color=$((intense + 37));;
      fg|foreground) 
        let -i flags[${#flags[@]}]=$((0 + color))
        printf "\e[%sm" "${flags[*]}"
        unset flags[@] # reset
        let color=0  # reset
      ;;
      bg|background) 
        let -i flags[${#flags[@]}]=$((10 + color))
        printf "\e[%sm" "${flags[*]}"
        unset flags[@] # reset
        let color=0
      ;;
      reset)
        printf "\e[0m\e[39m";;
      *) # all other text
        printf "%s" "$i";;
    esac
  done
  # always reset at the end.
  printf "\e[0m\e[39m"
}

# Prints nicely formatted log messages.
# Examples
#  status -t OK -m "This is a good message"
#  status -t ERROR -m "This is a bad message"
#  status -v "FAIL" -t "FAIL" -m "this message has custom type flag (-v)"
status () {
  local result=""
  local keytext=""
  OPTIND=1 # always reset the options scan for this method.
  while getopts "t:m:v:" opt; do
    case $opt in
      v) # Set the specific type text (override default)
        keytext="${OPTARG}"
        ;;
      t) # Set the type of the message (colored field)
        case "${OPTARG}" in 
          OK|PASS) printf -v result "(%s)" "$(generate_color_terms bold green fg ${keytext:-OK})";;
          ERR|ERROR) printf -v result "(%s)" "$(generate_color_terms bold red fg ${keytext:-ERROR})";;
          WARN) printf -v result "(%s)" "$(generate_color_terms bold yellow fg ${keytext:-WARN})";;
          *) printf -v result "(%s)" "$(generate_color_terms bold purple fg ${keytext:-OPTARG})";;
        esac
        ;;
      m) # Append the message text
        printf -v result "%s %s" "$result" "$OPTARG"
        ;;
    esac
  done
  printf "%s\n" "${result}"
}


fail(){
  err=$1; shift 1;
  status  -t ERROR -m "$@" >&2
  exit $err
}

warn () {
  status  -t ERROR -m "$@" >&2
}

info () {
  status  -t INFO -m "$@"  >&2
}

good () {
  status  -t OK -m "$@" >&2
}

