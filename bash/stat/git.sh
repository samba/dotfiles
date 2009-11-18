#!/bin/bash


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
	gitprint="${gitprint}\e[01;31mÂ\e[0m"
fi

# divergence state
if [[ "${gitstatus}" =~ ${patterns[2]} ]]; then
	# yellow bold
	gitprint="${gitprint}\e[01;33mD\e[0m"

	# remote state
elif [[ "${gitstatus}" =~ ${patterns[1]} ]]; then
	divergence=
	case ${BASH_REMATCH[1]} in
		ahead) divergence='^';;
		*) divergence='<';;
	esac
	gitprint="${gitprint}\e[01;33m${divergence}\e[0m"
fi


# branch state
if [[ "${gitstatus}" =~ ${patterns[0]} ]]; then
	# blue bold
	printf -v gitprint "(\e[01;34m%s\e[0m) %s" ${BASH_REMATCH[1]} "$gitprint"
fi

[ -z "$gitprint" ] || echo -e "git: $gitprint "
	}

git.directoryStatusPrompt $@
