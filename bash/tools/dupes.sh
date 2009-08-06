#!/bin/bash

function s.fdupes () {
	declare indexdir=`mktemp -d /tmp/dupes.XXXXXXX` fconnection="" verbose= dolink= auto= listonly=n
	OPTIND=1
	while getopts :alvshc:p: Option; do
		[ -z $verbose ] || echo "getopts: Parsing[ $OPTIND; $Option; $OPTARG ];">&2
		case $Option in
			a) auto="-a";;
			v) verbose="-v";;
			s) dolink="-s";;
			h) dolink="-h";;
			c) export fconnection="$OPTARG";;
			# add the path to the current connection
			p) printf -v t "%s/path.%s" "$indexdir" "$fconnection"; echo "$OPTARG" >> "$t";;
			l) export listonly=y;;
		esac
	done

	local i; declare iconnection='' indexpath='';
	for i in `ls $indexdir/path.*`; do
		[ ! -f "$i" ] && continue;
		b=`basename $i`
		case $b in
			path.|path.localhost) iconnection=''; indexpath="$indexdir/index.localhost";;
			*) iconnection="-c ${b#path.}"; indexpath="$indexdir/index.${b#path.}";;
		esac
		dupes.index -R -i $i $iconnection $verbose > $indexpath &
	done

	echo "Waiting for host(s) to finish indexing..."
	wait

	for i in `ls $indexdir/index.*`; do
		b=`basename $i`
		iconnection=${b#index.};
		# add a field for the connection string	
		sed "s%  %\t$iconnection\t%" -i $i;
	done
	# filter the whole collection for dupes
	cat $indexdir/index.* | sort -k 1 | uniq -D -w 32 > $indexdir/index_dupes_only

	# DEBUG
	# less $indexdir/index_dupes_only
	
	if [ "$listonly" = 'y' ]; then
		cat $indexdir/index_dupes_only;
	else 
		dupes.rm $verbose -i $indexdir/index_dupes_only $auto $l 
	fi

	rm -rf $indexdir;
}

# index and identify duplicates remotely and locally. {{{
function dupes.index () {
	declare paths=`mktemp` verbose=no rawmd5="| uniq -D -w 32" connection= cmd=
	OPTIND=1
	while getopts :vRc:i:p: O; do
		# echo "getopts: Parsing[ $OPTIND; $O; $OPTARG ];">&2
		case $O in
			c) connection="$OPTARG";;
			p) echo "$OPTARG" >> $paths;; # add this path...
			i) cat "$OPTARG" >> $paths;; # add paths from file
			v) verbose=yes;;
			R) rawmd5='';;
		esac
	done

	[ $verbose = 'yes' ] && echo "Indexing: `cat $paths`" >&2


	cmd="find %s -type f -print0 | xargs -0 md5sum | sort -k 1 $rawmd5;"
	printf -v cmd "$cmd" "`cat $paths`"
	rm $paths

	
	if [ $verbose = 'yes' ]; then
		echo "Connection is: $connection" >&2
		echo "Command is: $cmd" >&2
	fi

	if [ -z $connection ]; then
		# execute locally
		eval $cmd
	else
		# execute remotely
		[ $verbose = 'yes' ] && echo "Running remotely: $connection $cmd" >&2
		ssh $connection "$cmd"
	fi

}
# }}}
# remove duplicates provided a sorted index of duplicates as provided via s.fdupes {{{
# index format: <MD5sum>\t<user@host|localhost>\t<path>
function dupes.rm () {
	local auto=no verbose=no index= mklink=no emptydirs=no pretend=no
	local uniqmd5=`mktemp /tmp/dupes.rm.md5.XXXX` selection=`mktemp /tmp/dupes.rm.sel.XXXX`
	OPTIND=1;
	while getopts ":avi:shP" Option; do
		case $Option in
			a) auto=yes;;
			v) verbose=yes;;
			s) mklink=soft;;
			h) mklink=hard;;
			i) index="$OPTARG";;
			P) pretend=yes;; # NOT IMPLEMENTED
		esac
	done

	[ ! -f  "${index}" ] && { echo "specify an index file. [$index]" >&2; return 1; }
	
	numindex=`cat $index | wc -l`	
	# collect uniq MD5 hashes
	uniq -w 32 $index | cut -f 1 > $uniqmd5;
	numpairs=`cat $uniqmd5 | wc -l`
	[ "$verbose" = 'yes' ] && echo "Total duplicates: $numindex; Total Pairs: $numpairs"
	
	[ "$numpairs" -lt 1 ] && { echo "No duplicates specified in index.">&2; return 2; }

	cut -f 2 $index | sort -u  > $index.hostindex

	items=`mktemp /tmp/dupes.rm.items.XXXX`
	for md5 in $(cat $uniqmd5); do
		# all items matching this MD5
		grep -E "^$md5" $index | cut -f 2,3  > $items
		l=`grep -E '^localhost' $items | head -n 1 | cut -f 2`
		size=''
		if [ ! -z "$l" ]; then
			# get size of local file
			size="($(stat -L --printf='%s' "$l") bytes)"
		else
			size="(all remote)"
		fi
		# print the set {{{
		i=0; echo "files matching: $md5 $size" >&2
		if [ $auto = 'yes' ]; then
			echo 1 | menu -i $items -s 1,2 -r 1,2 -o $selection
		else
			menu -o $selection -i $items -s 1,2 -r 1,2 -p "keep files"
		fi
		# }}}

		# separate the sheep from the goats
		grep -E '^-' $selection > $selection.del
		grep -E '^\+' $selection > $selection.keep

		for i in $(cat $index.hostindex); do
			cut -f 2,3 $selection.del | grep -E "^$i" | cut -f 2 > $selection.del.$i
			[ `cat $selection.del.$i | wc -l` -lt 1 ] && continue;
			# TODO: implement linking as far as possible

			# coordinate deletion
			if [ "$i" = 'localhost' ]; then
				rm -v `cat $selection.del.$i`
			else
				ssh $i -C "rm -v `cat $selection.del.$i`" &
			fi
		done

		echo "Waiting on host(s) to finish deleting files."
		wait

#		k=`grep -E '^\+' $selection | cut -f 2,3 | head -n 1`
#		case $mklink in
#			soft|hard) linktype=; [ $mklink = 'soft' ] && linktype=-s; 
#			if [ ! -z $k ]; then
#				while read f; do
#					ln -v -f $linktype `readlink -f $k` $f
#				done < $selection.del
#			else
#				echo "None kept, removing.";
#				rm -v -i `cat $selection.del`;
#			fi
#			;;
#			*) echo "Deleting duplicates:"; rm -v `cat $selection.del`;;
#		esac
#


	done 
	rm $uniqmd5 $selection*	
}

# }}}

# this is an auxiliary function - other dupes functions no longer require it
function md5.recursive () {
	[ $# -lt 1 ] && { echo "md5.recursive: specify at least one path to index." >&2; return 1; }
	find $@ -type f -print0 | xargs -0 md5sum
}



# vim: foldenable foldmethod=marker
