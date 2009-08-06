#!/bin/bash

# a simple alternative to the watch command

function s.watch () {
    OPTIND=1 freq=5 clear=y date=y
    while getopts ':f:c' Option; do
	case $Option in
	    f) freq=$OPTARG;;
	    c) [ $clear = 'y' ] && clear=n || clear=y;;
	    d) [ $date = 'y' ] && date=n || date=y;;
	esac
    done
    shift $(( OPTIND - 1 ))

    while sleep $freq; do
	[ $clear = 'y' ] && clear;
	[ $date = 'y' ] && date;
	$@
    done
}
