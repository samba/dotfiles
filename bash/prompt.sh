#!/bin/bash

# If not running interactively, don't do anything
if [ ! -z "$PS1" ]; then

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
		# flags: 
		#		\j: current jobs  
		#		\#: command number
		#		\!: command history index
		#		\t: time
		#		\d: date
		#		\u: user
		#		\h: host
		#		\W: working directory basename

		
		color_now=36 # cyan
		color_user=32 # green
		color_host=33 # yellow
		color_dir=34 # blue
		color_chroot=31 # red
		color_shell=0 # none

		# directories on the stack: yellow	
		# dirs='dirs: \[\e[00;33m\]${#DIRSTACK[@]}\[\e[0m\];'


		# username: red, if root or UID=0
		if [ $USER = 'root' ] || [ $UID -eq 0 ]; then 
			color_user=31; 
			color_shell=31;
		fi
		
		printf -v now '\[\e[00;%dm\]\\t\[\e[0m\]' $color_now
		printf -v user '\[\e[01;%dm\]\u\[\e[0m\]' $color_user
		printf -v host '\[\e[01;%dm\]\h\[\e[0m\]' $color_host
		printf -v workdir '\[\e[01;%dm\]\W\[\e[0m\]' $color_dir
		printf -v chroot '\[\e[01;%dm\]%s\[\e[0m\] ' $color_chroot "$ch" # trailing space
		printf -v shell '\[\e[00;%dm\]\\$\[\e[0m\] ' $color_shell # trailing space


		# Throw it all together
		printf -v PS1 '%s%s %s@%s %s %s' "$chroot" "$now" "$user" "$host" "$workdir" "$shell"

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

	# unset color_prompt force_color_prompt

fi

