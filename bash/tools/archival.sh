#!/bin/bash

function squash () {
    OPTIND=1
   # TODO: friendly squashfs handling 
}



function tar.show () {
	local file="$1" list=$(mktemp) showHeading=y; shift;

	until [ $# -eq 0 ]; do
		case $1 in
			-g) tar.grep -l "$file" $2 >>$list; shift;;
			-f) tar.find "$file" $2 >>$list; shift;;
			-H) showHeading=n;;
			*) echo "$1" >> $list;;
		esac
		shift
	done

	while read i; do
		[ "$showHeading" = 'y' ] && printf "\n### %s\n" "$i" 
		tar -Oxf "$file" "$i"
		[ "$showHeading" = 'y' ] && printf "\n\n"
	done < $list

	rm $list
}

function tar.grep () {
	local listonly=n
	[ "$1" = '-l' ] && { listonly=y; shift; }
	local file="$1" index=$(mktemp) matches=$(mktemp); shift;
	[ $# -ne 0 ] || { echo 'I need something to do with these files...'>&2; return 1; }

	original_IFS="${IFS}"
	IFS=$'\012' # a newline

	for i in $(tar -tf "$file" | grep -v '/$'); do
		if [ "$listonly" != 'n' ]; then
			grepargs='-q' # quiet mode, exits faster
		fi
		tar -Oxf "$file" "$i" | grep $grepargs -n $@ > $matches
		[ $? -eq 0 ] || continue; # skip the rest of this if grep found nothing
		if [ "$listonly" = 'n' ]; then
			printf '# file: %s\n' "$i"
			sed 's/^/\t/' $matches # show matches with indentation
		else
			printf '%s\n' "$i"
		fi
	done


	IFS="${original_IFS}"

	rm $index $matches
}

function tar.find () {
	local file="$1"; shift;
	[ "$file" = '-h' ] && {
		echo "Prints filenames from a tarball, filtered through grep. Arguments are passed directly to grep" >&2
		return 1
	}
	tar -tf "$file" | grep $@
}



# vim: foldenable foldmethod=marker
