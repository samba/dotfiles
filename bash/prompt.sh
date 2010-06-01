
# If not running interactively, don't do anything
if [ ! -z "$PS1" ]; then
   
  black="\[\033[0;30m\]"
  blue="\[\033[0;34m\]"
  green="\[\033[0;32m\]"
  cyan="\[\033[0;36m\]"
  red="\[\033[0;31m\]"
  purple="\[\033[0;35m\]"
  brown="\[\033[0;33m\]"
  light_gray="\[\033[0;37m\]"
  dark_gray="\[\033[1;30m\]"
  light_blue="\[\033[1;34m\]"
  light_green="\[\033[1;32m\]"
  light_cyan="\[\033[1;36m\]"
  light_red="\[\033[1;31m\]"
  light_purple="\[\033[1;35m\]"
  yellow="\[\033[1;33m\]"
  white="\[\033[1;37m\]"
  no_color="\[\033[0m\]"

  hostname_color="$white"
  suffix_count=1
  suffix=""

  if [ $UID -eq 0 ]; then
    user_color="$light_red"
  else
    user_color="$light_green"
  fi

  if [ -n "$PROMPT_HOSTNAME_COLOR" ]; then
    printf -v hostname_color '\[\033[%s\]' $PROMPT_HOSTNAME_COLOR
  fi
  if [ -n "$PROMPT_SUFFIX_COUNT" ]; then
    suffix_count=$PROMPT_SUFFIX_COUNT
  fi

  for ((i=1; i<=$suffix_count; i++)); do suffix="${suffix}>"; done;


  PS1="${no_color}\u${hostname_color}\H${user_color}<${no_color}\W${user_color}${suffix} ${no_color}"
  PS2='\[\e[00;33m\]>\[\e[0m\] '
  PS3='> ' # PS3 doesn't get expanded like 1, 2 and 4
  PS4='\[\e[01;31m\]+\[\e[0m\]'
fi
#export PROMPT_COMMAND=set_prompt
