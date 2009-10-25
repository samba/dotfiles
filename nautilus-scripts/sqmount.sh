#!/bin/sh

LOG=${HOME}/.sqmount-log
mnt=/media/sq # base directory for mounting

date >>$LOG
echo "pwd: $(pwd); args: $@" >> $LOG
echo "paths: $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" >>$LOG
echo "uris: $NAUTILUS_SCRIPT_SELECTED_URIS" >>$LOG
echo "curi: $NAUTILUS_SCRIPT_CURRENT_URI" >>$LOG
echo "geom: $NAUTILUS_SCRIPT_WINDOW_GEOMETRY" >> $LOG


exec 1>>$LOG 2>>$LOG
files=$(mktemp)
echo "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" > $files


d=$(date +%N);

while read f; do
	# skip empty ones
	[ -z "$f" ] && continue
	# skip non-squashfs files
	file -b "$f" | grep -iq '^squashfs' || continue
	s=$mnt/$d/$(basename "$f")
	# mount the file (making the directory path as needed)
	gksudo "mkdir '$s' -p"
	gksudo "mount -v -o loop,uid=$(id -u) -t squashfs '$f' '$s'"
done < $files

rm $files

exec 1<&- 2<&-

