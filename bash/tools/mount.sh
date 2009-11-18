#!/bin/bash

# enhance the 'mount' call for convenience
# eventually also simplify edits of /etc/fstab


function mountall () {
OPTIND=1 VERBOSE=n VERB=mount
while getopts ':vu' O; do
	case $O in
		v) export VERBOSE=y ;;
		u) export VERB=umount ;;
	esac
done

[ $VERBOSE = 'y' ] && v='-v' || v='';
while read dev mountpoint type opts; do
	if [ -z $dev ]; then continue; fi


	[ -z $type ] || printf -v type '-t %s' $type
	[ -z $opts ] || printf -v opts '-o %s' $opts

	$VERB $v $type $opts $dev $mountpoint

done

}


function s.fstab () {
	OPTIND=1 VERBOSE=n f=/etc/fstab awkexp='! /^#/ && $%d ~ /%s/ { print $1; }' field=0 search=
	while getopts ':c:f:v' O; do
	case $O in 
		v) export VERBOSE=y;;
		f) export f=$OPTARG;; # allow override default /etc/fstab
		c) case $OPTARG in
			type) field=3;;
			device) field=1;;
			mountpoint) field=2;;
			option) field=4;; 
		esac ;;
	esac
	done
	shift $((OPTIND - 1))

	for search in $@; do
		printf -v exp "$awkexp" $field $search	
		[ $VERBOSE = 'y' ] && echo "AWK expression: $exp" >&2
		awk "$exp" $f
	done
}


	function mount.img.examine () {
	OPTIND=1 img= s= mountopt= parts= 
	while getopts ':i:d:o:sp:vu' Option; do
		case $Option in
			i) img=${OPTARG};;
			s) s=sudo;;
			o) mountopt="${OPTARG},";;
			p) parts="${OPTARG}";;
		esac
	done


	echo "examining partition table in the image" >&2
	b=$(basename $img);
	partitions=$(mktemp)
	$s sfdisk -l -uS $img 2>/dev/null | grep -E "^${b}" | tr '*' ' ' | tr -s ' ' | cut -d ' ' -f 1,2,3,4 > $partitions

	echo "partitions: ($partitions)" >&2 && cat $partitions >&2

	while read n start end sectors; do
		printf 'n:%s start:%s end:%s sectors:%s\n' $n $start $end $sectors >&2
		[ -z $start ] && { echo 'empty start' >&2; continue; }
		[ "$end" = '-' ] && { echo 'blank end' >&2; continue; }
		i=$( echo $n | sed "s%$b%%" )
		#	if [ ! -z $parts ]; then i
		#		echo "$parts" | tr ',' '\n' | grep -E "^$i" || { echo 'no partitions'; continue; }
		#	fi
		printf -v opt "%sloop,offset=%d" "${mountopt}" $((start * 512))
		printf "%s\t%s\t%s\n" "$img" "./$i" "$opt"
	done  < $partitions


	rm $partitions

}


function mount.img () {
OPTIND=1 img= dir= s= mountopt= parts= VERBOSE=n mode=mount
while getopts ':i:d:o:sp:vu' Option; do
	case $Option in
		i) img=${OPTARG};;
		d) dir=${OPTARG};;
		s) s=sudo;;
		o) mountopt="${OPTARG},";;
		p) parts="${OPTARG}";;
		v) VERBOSE=y;;
		u) mode=umount;;
	esac
done
[ -f "$img" ] || return 1;
[ -d "$dir" ] || return 2;

b=$(basename $img);
if [ $VERBOSE = 'y' ]; then
	v='-v'
	exec 5>&2
else
	v=''
	exec 5>/dev/null
fi

mountopt="$mountopt,loop,uid=$USER"

echo 'Trying to mount' $b 'to dir' $dir >&5
# first try mounting it directly, assuming it's just a partition
case $mode in
	mount) 
	$s mount $v -o $mountopt $img $dir 2>&5
	ret=$?
	case $ret in
		0) echo "success" >&5;;
		32)
		sudo=''; [ "$s" = "sudo" ] && sudo=-s
		mount.img.examine -i $img $sudo -p $parts -o $mountopt | while read I D O; do
		$s mkdir $v -p $dir/$D 2>&5
		$s mount $v -o $O $I $dir/$D 2>&5
	done

	ret=$?;
	;;
	*) echo "unknown error: $ret" >&5;;
esac
;;
umount) 
$s umount $v $dir 2>&5
ret=$?
case $ret in
	0) echo "success" >&5;;
	1) 
	mount.img.examine -i $img $sudo -p $parts -o $mountopt | while read I D O; do
	$s umount $v $dir/$D 2>&5
done

;;
*) echo "unknown error: $ret" >&5;;			

		esac
		;;
	esac


	exec 5>&-
	return $ret
}

