#!/bin/bash

ldd_actual () {
	list=/tmp/list.$(date +%N)
	ldd $@ | sed -r '/^[^\t]/d; s/(^\t(.*)=> |\(.*\))//g; /^\//!d;' > $list
	while read i; do
		while [ -L "$i" ]; do
			i="$(dirname "$i")/$(readlink "$i")"
		done
		[ -f "$i" ] && { echo "$i"; continue; }
		printf "%s\tnot found\n" "$i"
	done < $list

	rm $list
}


function ldd_copy () {
	OPTIND=1 source='' DESTDIR='' verbose='n' root='/'
	while getopts ':b:d:vr:' O; do
		case $O in
			b) source=$OPTARG;;
			d) DESTDIR=$OPTARG;;
			v) verbose='y';;
			r) root="$OPTARG";;
		esac
	done

	if [ ! -f $source ] || [ ! -d $DESTDIR ]; then
		return 2;
	fi

	source=`readlink -f $source`
	mkdir -p ${DESTDIR}/`dirname $source`
	cp $source ${DESTDIR}/$source
	

	# an alternative (ldd output) parser:  sed -r '/^[^\t]/d; s/(^\t(.*)=> |\(.*\))//g; /^\//!d; '

	# Copy the dependant libraries - borrowed from Debian initramfs-tools
	for x in $(ldd ${source} 2>/dev/null | sed -e '
	    /\//!d;
	    /linux-gate/d;
	    /=>/ {s/.*=>[[:blank:]]*\([^[:blank:]]*\).*/\1/};
	    s/[[:blank:]]*\([^[:blank:]]*\) (.*)/\1/' 2>/dev/null); do

		# Try to use non-optimised libraries where possible.
		# We assume that all HWCAP libraries will be in tls.
		nonoptlib=$(echo "${x}" | sed -e 's#/lib/\(tls\|i686\).*/\(lib.*\)#/lib/\2#')

		if [ -e "$root/${nonoptlib}" ]; then
			x="${nonoptlib}"
		fi

		libname=$(basename "${x}")
		dirname=$(dirname "${x}")

		mkdir -p "${DESTDIR}/${dirname}"
		if [ ! -e "${DESTDIR}/${dirname}/${libname}" ]; then
			v=''
			[ "$verbose" = 'y' ] && v='-v'
			cp $v "$root/${x}" "${DESTDIR}/${dirname}"
		fi
	done


}
