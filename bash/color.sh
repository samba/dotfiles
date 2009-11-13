#!/bin/sh
# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    linux|xterm*|gnome*) color_prompt=yes;;
esac

# COLORTERM is set by gnome-terminal, and some others define a TERM containing 'color'
echo "$TERM" | grep -q color && export color_prompt=yes;
[ -z "$COLORTERM" ] || export color_prompt=yes;

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
	else
		color_prompt=
	fi
fi


# if [ "$color_prompt" = 'yes' ]; then
# 	# colors for LESS and man pages..
# 	export LESS_TERMCAP_mb=$'\E[01;31m' # begin blinking
# 	export LESS_TERMCAP_md=$'\E[01;38;5;74m' # begin bold
# 	export LESS_TERMCAP_me=$'\E[0m' # end mode
# 	export LESS_TERMCAP_se=$'\E[0m' # end standout-mode
# 	export LESS_TERMCAP_so=$'\E[38;5;246m' # begin standout-mode - info box export LESS_TERMCAP_ue=$'\E[0m' # end underline
# 	export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline
# 
# fi




