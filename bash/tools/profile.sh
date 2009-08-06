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

if ! [[ "$0" =~ `basename $SHELL`$ ]]; then
	v=$1; shift;
	case $v in
		replicate) $v $@;;
		*) echo "$0 was called without a verb.";;
	esac
#else
#	echo "$0 matches $SHELL" >&2
fi


# vim: foldmethod=marker
