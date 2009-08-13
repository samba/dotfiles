#!/bin/bash

# friendly debian extractor... {{{
function dpkg.extract () {
	declare outputdir= debfile=
	while getopts ":f:d:" Option; do
		case $Option in
			f) export debfile=$OPTARG;;
			d) export outputdir=$OPTARG;;
		esac
	done
	if [[ -z $debfile || ! -f $debfile ]]; then
		# usage
		echo "deb.extract -f <file.deb> [ -d <output directory> ]";
	else
		[ -z $outputdir ] && outputdir=`basename $debfile .deb` && echo "automatic: $outputdir" >&2
		mkdir -p $outputdir/DEBIAN
		
		echo "extracting to: $outputdir"
		
		cd $outputdir; 
		dpkg-deb -e $debfile ./DEBIAN/
		dpkg-deb -x $debfile ./
		cd $OLDPWD
	fi
}
# }}}

function whichdpkg () {
    list=$(mktemp)
    for i; do
	readlink -f $( which $i )
    done > $list
    dpkg-query -S $(cat $list) | cut -f 1 -d ':' | sort -u
    rm $list
}




function dpkg.prepdir () {
 	for i; do
		mkdir -p $i/DEBIAN
		touch $i/DEBIAN/{control,preinst,postinst,prerm,postrm,conffiles,triggers}
		chmod +x $i/DEBIAN/{preinst,postinst,prerm,postrm}
		for j in $i/DEBIAN/{preinst,postinst,prerm,postrm}; do
			[ `cat $j | wc -l` -gt 1 ] && continue;
			cat >>$j <<-EOF
				#!/bin/bash
				# script: `basename $j`
			EOF
		done

		l=`cat $i/DEBIAN/control | wc -l`
		[ $l -lt 3 ] && cat >>$i/DEBIAN/control <<-EOF
			Package:
			Version:
			Architecture:
			Maintainer:
			Depends:
			Section:
			Description:

EOF
	done
}

function dpkg.control.debname () {
	local i= j=
	for i; do
		if [ -f $i ]; then
			name=$(dpkg.control.getfield $i Package Version Architecture | tr -s "\n\t " "_" | sed 's/_$//')
			echo $name.deb
		elif [ -d $i ]; then
			dpkg.control.debname $i/DEBIAN/control
		fi
	done
}

function dpkg.control.getfield () {
	c=$1; shift;
	for i; do
		sed "/^$i:/{ s/$i:[\t ]*//; p; }; d;" $c
	done 
}


function dpkg.build () {
	declare Recursive=no OPTIND=1;
	while getopts :R O; do
		case $O in
			R) export Recursive=yes;;
		esac
	done
	shift $(( OPTIND - 1 ))

	for i; do
		if [ $Recursive = 'yes' ]; then
			dpkg.build $(find $i -name control | while read f; do dirname $(dirname $f); done)
		else
			[ -d $i ] && [ -f $i/DEBIAN/control ] && dpkg-deb --build $i $(dirname $i)/$(dpkg.control.debname $i/DEBIAN/control)
		fi
	done
}


# vim: foldenable foldmethod=marker
