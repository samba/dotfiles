#!/bin/bash

# this script is basically a set of SSH-related commands to run based on the current hostname.


for i in ${HOME}/.ssh/sock/*; do
	echo $i >&2	
done



function tunnel () {
export PSBIN=ps
OPTIND=1
while getopts c:lk:sa O; do
    case $O in
	c) h=$OPTARG; 
	    # create a tunnel if there isn't one already
	    tunnel -l | grep "\-Nf $h" >/dev/null && return 0;
	    ssh -Nf $h -o ConnectTimeout=5 -o BatchMode=yes -o TCPKeepAlive=yes -o Compression=yes
	;;
	l) $PSBIN -C ssh -o pid,command | grep '\-Nf';;
	k) kill $(tunnel -l | grep $OPTARG | tr -s ' ' '\t' | cut -f 2);;
	s) tunnel_count=$( tunnel -l | wc -l )
	    echo -en "ssh: \e[32m$tunnel_count\e[0m, \e[33m$(ls ~/.ssh/sock/ -1 | wc -l)\e[0m;";
	;;
	a) # auto connect mode
	h=$(hostname)
	case $h in
	#    fenrir|ragnorak|wssbriesemeister) 
	#    tunnel -c gateway
	#    ;;

	#    fenrir|celery|gateway) 
	#    tunnel -c corp.safedesk.com 
	#    ;;

		*) echo nothing to do for host $h >&2;;

	esac
	;;

	*) echo 'Unknown option' $O $OPTARG $OPTIND;;
    esac
done
}

if [ $isLoginShell = 'yes' ] && [ -d $HOME/.ssh/sock ]; then
    [ -z $STATUS_FUNCS ] && STATUS_FUNCS=$(mktemp)
    echo 'tunnel -s' >> $STATUS_FUNCS
    tunnel -a
fi
# vim: foldenable foldmethod=marker
