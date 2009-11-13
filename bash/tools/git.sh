#!/bin/bash

function git.help  () {
cat <<EOF
    git.recursive [ -d path/ ] [ -c command ] 
	if no command given, list git directories
	else execute command for each 
    
    git.addlocal [ -u user ] -d projectdir  [ -r remoterepo ]
	create new projectdir relative to user's home directory
	if remote repo provided, clone it
    

EOF
}

# GIT ABSTRACTIONS {{{
function git.recursive () {
	OPTIND=1 dir= command= list=`mktemp`
	while getopts :d:c: O; do
		case $O in
			d) dir=$OPTARG;;
			c) command=$OPTARG;;
		esac
	done


	find $dir -type d -name .git > $list
	[ `cat $list | wc -l` -gt 0 ] || return 1; # fail if no git directories are found

	if [ -z $command ]; then
		cat $list # print the list of no command given
	else
		while read i; do
		    echo $i; 
			cd $i/../;
			git $command # NOTE: this doesn't play nice with commits - editors require STDIN to be the shell, which is blocked by the loop
			cd $OLDPWD
		done < $list
	fi	
}

function git.addlocal () {
	declare OPTIND=1 u=git d='' r='' b='$HOME'
	while getopts :u:d:r: O; do
		case $O in
			u) export u=$OPTARG;;
			d) export d=$OPTARG;;
			r) export r=$OPTARG;;
		esac
	done
	
	if [ -z $d ]; then echo 'Specify a project directory.'; return 1; fi
	
	b=`grep $u /etc/passwd | cut -f 6 -d :`

	script=`mktemp /tmp/gitscript.XXXX`
	echo "script: $script" >&2;

	cat >$script <<-EOF
	#!$SHELL
	EOF

	if [ ! -z $r ]; then
		cat >>$script <<-EOF
		mkdir `dirname $b/$d` -p
		git clone $r $b/$d
		EOF
	else
		cat >>$script <<-EOF
		mkdir $b/$d -p
		cd $b/$d
		git init
		EOF
	fi

	chmod +rx $script
	sudo chown $u: $script
	sudo -u $u $SHELL $script 
}

function git.headcommit () {
	# print the commit ID of the current HEAD
	for i; do
		[ ! -d $i ] && continue;
		cd $i;
		git log -n 1 | head -n 1 | awk '{ print $2; }'
		cd $OLDPWD
	done
}

function git.snapshot () {
	for i; do
		tar -czvf $i/../$(basename $i).$(date +%s).tar.gz $i --exclude=.git --exclude=*.deb
	done
}

# }}}

