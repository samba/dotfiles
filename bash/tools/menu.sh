#!/bin/bash

# accepts files of newline-separated items
# prints the same list; selected items prefixed with +, otherwise -
function menu () {
	declare sedscript=`mktemp` selection= output=`mktemp` \
		returnfield=1 showfield=1 delim= limit= promptstr=''
	require='sed seq cut'
	which $require >/dev/null || { echo "Required: $require">&2 && return 1; };

	OPTIND=1
	while getopts ":i:o:l:r:s:d:a:p:" Option; do
		case $Option in
			a) export autoselect="$OPTARG";;
			i) cat $OPTARG >> $output;;
			o) mv $output $OPTARG; export output=$OPTARG;;
			r) export returnfield=$OPTARG;;
			s) export showfield=$OPTARG;;
			l) export limit=$OPTARG;;
			d) export delim=$OPTARG;;
			p) export promptstr="${OPTARG}";;
		esac
	done 

	# defaults
	[ -z $limit ] && limit=`cat $output | wc -l` # number of options available
	[ ! -z $delim ] && delim="-d $delim"

	local i=0
	cut -f $showfield $delim $output | while read item; do
		[ -z "$item" ] && continue;
		i=$((i+1));
		printf "%5d. %s\n" $i "$item" 
	done

	 
	# everything starts deselected
	echo 's/^/-\t/;' > $sedscript;
	while [ 1 ]; do 
		read -p "${promptstr} #$PS3 "  selection
		[ -z $selection ] && continue;
		for s in ${selection}; do
			if [ "$s" = 'all' ]; then
				seq 1 $limit
			elif [ "$s" = 'none' ]; then
				echo "Selected NONE! OK, if you say so..." >&2;
			elif [[ $s =~ ^[0-9]+$ ]]; then 
				echo $s;
			elif [[ $s =~ ^[0-9]+-[0-9]+$ ]]; then 
				seq ${s%-*} ${s#*-} 
			elif [[ $s =~ ^[0-9]+-[0-9]+-[0-9]+$ ]]; then
				seq `echo $s | tr -s '-' ' '`
			else 
				echo "unrecognized specifier: $s; please try again."; >&2
				continue;
			fi 
		done | head -n $limit | while read n; do
			# activate the specified item
			[ $n -gt 0 ] &&	echo  ${n} 's/^-/+/'
		done  >> $sedscript
		break;
	done	
	cut -f $returnfield $delim $output > $output.ret
	mv $output.ret $output
	sed -f $sedscript -i $output

}

