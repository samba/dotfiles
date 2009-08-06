#!/bin/bash

# for each stdin; execute this command... like xargs {{{
function each () {
	singular=0; items=`mktemp`
	OPTIND=1
	while getopts ":s" Option; do
		case $Option in 
			s) singular=$(( (singular + 1) % 2 ));; # toggle
		esac
	done

	while read item; do
		[ $singular -eq 0 ] && $@ $item || echo $item > $items;
	done

	[ $singular -ne 0 ] && $@ `cat $items`;

	rm $items
}
# }}}

function emptydirs (){
	find $@ -depth -type d -empty
}

# recursive replacement
function rreplace () {
	declare paths=`mktemp` regex=`mktemp` VERBOSE=n; 
	OPTIND=1
	while getopts ":p:r:v" Option; do
		case $Option in
			p) echo "$OPTARG" >> $paths;;
			r) echo "$OPTARG" >> $regex;;
			v) VERBOSE=y;;
		esac
	done 
	
	[ $VERBOSE = 'y' ] && {
	    echo "Paths: "; cat $paths;
	    echo "Expressions: "; cat $regex;
	}
	sed -s -r -f $regex  -i $(find $(cat $paths) -type f)
}



function find.type () {
	local fs=$(mktemp) a=$(mktemp)
	until [ $# -eq 0 ]; do
		if [ -d "$1" ]; then
				echo "$1" >> $fs;
				shift;
				continue;
		elif [ -f "$1" ]; then
			echo "$1" >> $fs;
			shift;
			continue;
		else
			echo "\$2 ~ /$1/" >> $a;
			shift;
			continue;
		fi
	done
	sed '$! { s/$/||/; }' -i $a

	
	#	find packaging/ -type f | xargs file -F ::  | awk -F '::' '$2 ~ /XML/ || $2 ~ /HTML/ { print $1 }'

	
	find $(cat $fs) -type f | xargs file -F ::  | awk -F '::' "$(cat $a) { print \$1; }"
	rm $fs $a
}

# vim: foldenable foldmethod=marker