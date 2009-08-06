#!/bin/bash



function searchfolder () {
	declare dirpath= paths=absolute;
	OPTIND=1
	while getopts :d:r O; do
		case $O in
			d) dirpath=$OPTARG;;
			r) paths=relative;;
		esac
	done
	mkdir -p $dirpath;

	cd $dirpath;
	while read l; do
		case $paths in
			absolute) l=`readlink -f $l`;;
			relative) l=$l;;
		esac
		ln -s "$l"
	done
	cd $OLDPWD
}

function searchfolder.usage () {
	cat <<-EOF
	Example:	find ./ -name *.gz | searchfolder -d ../gzip-files

	'searchfolder' expects a directory specified on the command line, and reads the link targets on standard input (newline-separated)
EOF
}
