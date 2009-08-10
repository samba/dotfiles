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
		tar -czvf $(basename $i).$(date +%s).tar.gz $i --exclude=.git --exclude=*.deb
	done
}

function git.branchremote (){
	# this is a re-implementation of: http://github.com/webmat/git_remote_branch
	# http://github.com/webmat/git_remote_branch/blob/35f6af55ad1802a5368b9b9b0d1652a05de7d3c8/lib/git_remote_branch.rb
	mode="$1" branch="$2"; origin="${3:-origin}";
	shift 3;

	git rev-parse --git-dir &> /dev/null || return 0;
	curr_branch=$(git branch | grep -oE '^\* (.*)' | cut -c3-)

	case $mode in
		create) 
			git push $origin $curr_branch:refs/heads/$branch
			git fetch $origin
			git branch --track $branch $origin/$branch
			git checkout $branch
			;;
		publish)
			git push $origin $branch:refs/heads/$branch
			git fetch $origin
			git config branch.$branch.remote $origin
			git config branch.$branch.merge refs/heads/$branch
			git checkout $branch
		;;
		rename)
			git.branchremote create $branch $origin
			git push $origin :refs/heads/$curr_branch
			git branch -d $curr_branch
		;;
		delete)
			git push $origin :refs/heads/$branch
			[ "$brach" == "$curr_branch" ] && git checkout master
			git branch -d $branch
		;;
		track)
			git fetch $origin
		# TODO: improve this check to make sure a branch with **exactly** this name exists
			if git branch | grep $branch >/dev/null; then
				git config branch.$branch.remote $origin
				git config branch.$branch.merge refs/heads/$branch
			else
				git branch --track $branch $origin/$branch
			fi
		;;
		*)
esac

}


# }}}


# Integrating git status with shell prompts, etc
# derived from: http://gist.github.com/47267
function git.directoryStatusPrompt () {
    [ $? -eq 0 ] || return 0;
    git rev-parse --git-dir &> /dev/null || return 0;
    
    # search patterns: branch, remote, diverge
    patterns=( "^# On branch ([^${IFS}]*)" "# Your branch is (.*) of"  "# Your branch and (.*) have diverged" "untracked files present" "# Untracked files:" );

   
    gitstatus=$(git status 2>/dev/null)   gitprint=
   
    if [[ "${gitstatus}" =~ "working directory clean" ]]; then
	# green
	gitprint="${gitprint}\e[01;32m=\e[0m"
    else
	# yellow
	gitprint="${gitprint}\e[01;33m~\e[0m"
    fi
  
    if [[ "${gitstatus}" =~ ${patterns[3]} ]] || [[ "${gitstatus}" =~ ${patterns[4]} ]]; then
	# bold red
	gitprint="${gitprint}\e[01;31m⚡\e[0m"
    fi

    # divergence state
    if [[ "${gitstatus}" =~ ${patterns[2]} ]]; then
	# yellow bold
	gitprint="${gitprint}\e[01;33m↕\e[0m"

    # remote state
    elif [[ "${gitstatus}" =~ ${patterns[1]} ]]; then
	divergence=
	case ${BASH_REMATCH[1]} in
	    ahead) divergence='↑';;
	    *) divergence='↓';;
	esac
	gitprint="${gitprint}\e[01;33m${divergence}\e[0m"
    fi


    # branch state
    if [[ "${gitstatus}" =~ ${patterns[0]} ]]; then
	# blue bold
	printf -v gitprint "(\e[01;34m%s\e[0m) %s" ${BASH_REMATCH[1]} "$gitprint"
    fi

    [ -z "$gitprint" ] || echo -en "git: $gitprint "
}

[ -z $STATUS_FUNCS ] && STATUS_FUNCS=$(mktemp)
if [ -e $STATUS_FUNCS ]; then
    echo 'git.directoryStatusPrompt' >> $STATUS_FUNCS
fi
