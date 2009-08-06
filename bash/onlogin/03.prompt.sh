#!/bin/bash
# PROMPT {{{

# Note: these require the function 'color' to be defined already
# Also, some of the Git integration will adjust these values later

# If not running interactively, don't do anything
[ -z "$PS1" ] && return





function prompt_shell_status () {
    while read l; do
	printf '%s ' "$( eval $l  )"
	# TODO: properly wrap non-printing characters
	# | sed -r 's/\e\[([0-9]+[;]?)+m/\[\0\\]/g;'
    done < $STATUS_FUNCS
    
}

[ -z $STATUS_FUNCS ] && STATUS_FUNCS=$(mktemp)

# what kind of prompt we're actually going to display.
shell=basic
case $TERM in
    xterm*|gnome*|screen) shell=full;;
    *) shell=basic;;
esac


# what shell title sequence to use
case $TERM in
	xterm*) title='\[\e]0;\u@\h: \w\a\]';;
	screen*) title='\[\ek\e\\\]';;
	*) title='';;
esac


if [ "$color_prompt" = 'yes' ] && [ "$shell" = 'full' ]; then
    ch=''
    [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ] && ch="$(cat /etc/debian_chroot) "

    # NOTE: all non-printing characters must be surrounded by \[ and \]

    # jobs managed by the shell: blue
    jobs='jobs: \[\e[00;33m\]\j\[\e[0m\];'
    
    # directories on the stack: yellow	
    dirs='dirs: \[\e[00;33m\]${#DIRSTACK[@]}\[\e[0m\];'
    # command number (in this session): yellow; command history index: blue
    cmds='cmd: \[\e[00;33m\]#\#\[\e[0m\] \[\e[00;34m\]!\!\[\e[0m\];'
    
    # current date:
    now='now: \[\e[00;32m\]\d \t\[\e[0m\];'
    
    # username: green (red, if root or UID=0);
     usercolor=32
    if [ $USER = 'root' ] || [ $UID -eq 0 ]; then usercolor=31; fi
    printf -v user '\[\e[01;%dm\]\u\[\e[0m\]' $usercolor
    # hostname: yellow
    host='\[\e[01;33m\]\h\[\e[0m\]'
    # pwd basename: blue
    workdir='\[\e[01;34m\]\W\[\e[0m\]'

    
    # chroot indicator
    printf -v chroot '\[\e[01;31m\]%s\[\e[0m\]' "$ch"

    # Throw it all together
    printf -v PS1 '%s %s %s %s \t %s \\n%s%s%s @ %s : %s \$ ' "$jobs" "$dirs" "$cmds" "$now" "\$(prompt_shell_status)" "$title" "$chroot" "$user" "$host" "$workdir"

    PS2='\[\e[00;33m\]>\[\e[0m\] '
    PS3='> ' # PS3 doesn't get expanded like 1, 2 and 4
    PS4='\[\e[01;31m\]+\[\e[0m\]'

elif [ "$shell" = 'basic' ]; then # we assume color is supported
    # a basic shell, with some color
    
    # username: green (red, if root or UID=0);
    usercolor=32
    if [ $USER = 'root' ] || [ $UID -eq 0 ]; then usercolor=31; fi
    printf -v user '\[\e[01;%dm\]\u\[\e[0m\]' $usercolor
    # hostname: yellow
    host='\[\e[01;33m\]\h\[\e[0m\]'
    # pwd basename: blue
    workdir='\[\e[01;34m\]\W\[\e[0m\]'


    printf -v PS1 '%s%s @ %s : %s \$ ' "$title" "$user" "$host" "$workdir"
    
    PS2='\[\e[00;33m\]>\[\e[0m\] '
    PS3='> ' # PS3 doesn't get expanded like 1, 2 and 4
    PS4='\[\e[01;31m\]+\[\e[0m\]'

else # color is not supported, and we're not going to try a complex prompt
    # a very simple one, no color
    PS1='\u@\h:\W \$ ';
fi

unset color_prompt force_color_prompt
# }}}

