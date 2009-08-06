#!/bin/bash

# a tool by which files can be tagged. 
# files indexed NOT by name, but other characteristics


function filedb.init () {
    dir=$(pwd)
    while getopts :d: Option; do
	case $Option in
	    d) dir=$OPTARG;;
	esac
    done

    mkdir -p $dir/.db/tags
    rm $dir/.db/tags/* $dir/.db/{MD5,times}
    touch $dir/.db/{MD5,times}
    
}


function filedb.parentdb () {
    dir=$(pwd) OPTIND=1
    while getopts :d: Option; do
	case $Option in
	    d) dir=$OPTARG;;
	esac
    done

    dir=$(readlink -f $dir)

    while [ ! -d $dir/.db ]; do
	dir=$(dirname $dir)
	[ $dir = '/' ] && return 1;
    done

    echo $dir/.db;

}


function filedb.update () {
    db=$(filedb.parentdb) || return 1;
    auto=n OPTIND=1 list=$(mktemp)
    while getopts ':af:' Option; do
	case $Option in
	    a) auto=y;;
	    f) echo $OPTARG >> $list;;
	esac
    done
    
    dir=$(dirname $db)
    if [ $auto = 'y' ]; then
	find $dir/ -type f >> $list
    fi

    cd $dir
    while read f; do
	f=$(echo $f | sed "s%$dir%%")
	real_mtime=$(stat --printf='%Y' $f);
	real_namehash=$(echo $f | md5sum | cut -c 1-32);
	mtime=$(awk "\$1 ~ /^$real_namehash\$/ { print $2; }" $db/times);
	if [ ! -z $mtime ]; then
	    # we've seen this one
	    if [ $mtime != $real_mtime ]; then
		# TODO: the file's been changed, update your MD5sum
		
	    fi
	else
	    # the file is new, or has been moved
	    echo $namehash $mtime >> $db/times;
	    md5sum $f >> $db/MD5;
	fi
    done < $list
    cd $OLDPWD
}


function filedb.tag () {

}
