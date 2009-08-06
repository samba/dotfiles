#!/bin/bash

# My preferred settings for making CD/DVD images
function s.mkiso () {
	verbose=n encrypt=n input= output=
#	while getopts :veo:i:b: O; do
#		case $O in
#			e) encrypt=y;;
#			b) bootimg=$OPTARG;;
#			-) break;;
#		esac
#	done
#	shift $OPTIND;

	iso_opts=" -f -l -J -R -r -allow-leading-dots -iso-level 3 ";

	mkisofs $iso_opts $@

}
