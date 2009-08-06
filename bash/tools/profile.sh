#!/bin/bash

# profile replication {{{
function replicate () {
declare list= source_dir= target_dir= files=`mktemp` exclude=`mktemp` sedscript=`mktemp` verbose=n
	OPTIND=1
	while getopts :l:s:d:v Opt; do
	#	echo "getopts: [ $OPTIND; $Opt; $OPTARG ];" >&2
		case $Opt in
			l) export list="$OPTARG";;
			d) export target_dir="$OPTARG";;
			s) export source_dir="$OPTARG";;
			v) export verbose=y;
		esac
	done
	
	[ -f "$list" ] || { echo "Specify a sources list: $list" >&2; return 1; }
	[ -d "$target_dir" ] || { echo "Specify a target directory: $target_dir" >&2; return 2; }
	[ -d "$source_dir" ] || { echo "Specify a source directory: $source_dir" >&2; return 3; }

	[ "$verbose" = 'y' ] && echo "replicating verbosely." >&2

	# parse the list file
	grep -E '^-' $list > $exclude; # list file exclusion
	grep -E '^\+' $list | sed 's/^\+[ \t]*//' > $files; # list file enclusion
	grep -E '^\~' $list | sed 's/^\~//' > $sedscript; # list string replacements

# the command we want to run...
	rsync_cmd="rsync -ar --delete --delete-excluded $source_dir $target_dir"
	if [ "$verbose" = 'y' ]; then
		echo "rsync cmd: $rsync_cmd" >&2
		verbose_option=-v
	else
		verbose_option=''
	fi
	$rsync_cmd --files-from=${files} --exclude-from=${exclude} $verbose_option

	sed -f $sedscript -i `find $target_dir -type f`

# make a tarball of it too.
	target_tgz=`dirname $target_dir`/`basename $target_dir`.tar.gz 
	tar $verbose_option -czf $target_tgz $target_dir 2>&1 | grep -v 'Removing leading'

	rm $verbose_option $exclude $files $sedscript
}
# }}}

# Dotfiles online integration {{{
# A script to download from and upload to dotfiles.org

# Who are you? 
DFRoot=$HOME/.dotfiles
DFCredentials=$DFRoot/login

dotfiles () {
	source $DFCredentials
	DFSource="http://dotfiles.org/~$Username"
	DFList=${DFSource}/dotfiles.list

	push_real_dotfiles=y

	dotfiles_list=`mktemp`
	wget -U 'curl' $DFList -O $dotfiles_list 2>/dev/null
	# for some reason it comes in with funky end-of-line chars
	sed 's/[\r]//' -i $dotfiles_list
	echo >> $dotfiles_list # and just in case there is no trailing blank line, we add one

	if [ ! -z $1 ]; then 
	case $1 in 
		pull|download)
		while read d; do
			echo "Syncing: ${d}" >&2
			wget -U 'curl' $DFSource/${d} -O ${DFRoot}/${d} >/dev/null 2>/dev/null
			[ $? -ne 0 ] && echo "Pull failed: $d">&2;
		done < $dotfiles_list
		;;	
		push|upload)
		push_root=$DFRoot
		[ "$push_real_dotfiles" = 'y' ] && push_root=$HOME
		while read d; do
			description=${DFRoot}/${d}.description;
			if [ ! -r "${description}" ]; then
				echo "No description present for ${d}. Please update ${description} and push again. (Proceeding anyway...)">&2
				echo "## description for ${d}" > ${description}
				# $EDITOR ${DFRoot}/${d}.description || continue;
				[ `cat ${description} | wc -l` -gt 0 ] || continue;
			fi 
			echo "Uploading: ${d}" >&2
			target=`curl $DFSource/${d}/edit 2>/dev/null | \
				grep -E "<form method=\"post\" action=\"/update/[0-9]+\">" | \
				sed -r 's/^(.*)action="(.*)"(.*)$/\2/'`
			target="http://${Username}:${Password}@dotfiles.org${target}"

			# push the data via curl
			curl \
				--data-urlencode filename=$d \
				--data-urlencode contents@${push_root}/${d} \
				--data-urlencode description@${description} \
				$target >/dev/null 2>/dev/null
			[ $? -ne 0 ] && echo "Push failed: $d">&2;
		done < $dotfiles_list
		;;
		*) echo "Unknown verb: $1">&2;;

	esac
	else 
		echo "no verb."
	fi

	rm $dotfiles_list
}

# }}}

if ! [[ "$0" =~ `basename $SHELL`$ ]]; then
	v=$1; shift;
	case $v in
		replicate|dotfiles) $v $@;;
		*) echo "$0 was called without a verb.";;
	esac
#else
#	echo "$0 matches $SHELL" >&2
fi


# vim: foldmethod=marker
