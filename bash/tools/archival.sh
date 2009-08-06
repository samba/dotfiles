#!/bin/bash

function squash () {
    OPTIND=1
   # TODO: friendly squashfs handling 
}


function aes.compress () {
    OPTIND=1 Outfile=''
    while getopts ':f:' Opt; do
	case $Opt in
	    f) Outfile=${OPTARG};;
	esac
    done
    shift $((OPTIND +1 ))

    count=$#
    [ $count -eq 1 ] && [ -d $1 ] && count=2

    case $count in
	0) echo "Specify an input file." >&2; return 1;;
	1) [ -z "$Outfile" ] && Outfile="$1.aes";;
	*) [ -z "$Outfile" ] && Outfile=$(basename $(pwd)).$(date +%s).tar.gz.aes;;
    esac

    echo "$Outfile: $@" >&2

    case $count in
	0) echo "No files given." >&2;;
	1) gzip -c "$1" | aespipe -T -e AES256 -H rmd160 > "$Outfile";;
	*) tar -cz $@ | aespipe -T -e AES256 -H rmd160 > $Outfile;;
    esac
}


function archive () {
	local d=$(date +%F\ %H.%M.%S) dir= base= ext=
	for i; do
		if [ -f "$i" ]; then
			dir=$(dirname "$i") base=$(basename "$i") ext=${i##*.}
			cat "$i" | gzip > "$i.$d.gz"
		elif [ -d "$i" ]; then
			dir=$(dirname "$i") base=$(basename "$i")
			tar -czvf "$dir/$base.$d.tar.gz" "$i"
		else
			echo "Can't archive this: $i" >&2
		fi
	done
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


function cbz () {
	find $@ -mindepth 1 -maxdepth 1 -type d -exec zip -rm {}.cbz {} \;
}



# vim: foldenable foldmethod=marker
