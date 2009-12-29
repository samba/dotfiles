#!/bin/sh

LOG=${HOME}/.sqmount-log
mnt=/media/sq # base directory for mounting

date >>$LOG
echo "pwd: $(pwd); args: $@" >> $LOG
echo "paths: $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" >>$LOG
echo "uris: $NAUTILUS_SCRIPT_SELECTED_URIS" >>$LOG
echo "curi: $NAUTILUS_SCRIPT_CURRENT_URI" >>$LOG
echo "geom: $NAUTILUS_SCRIPT_WINDOW_GEOMETRY" >> $LOG

m="SquashFS Mounter"


exec 1>>$LOG 2>>$LOG
files=$(mktemp)
echo "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" > $files

dpkg -l squashfs-tools >/dev/null || gksudo -m "$m" "apt-get install squashfs-tools"


d=$(date +%N);

while read f; do
	# skip empty ones
	[ -z "$f" ] && continue
	# skip non-squashfs files
	file -b "$f" | grep -iq '^squashfs' || continue
	s=$mnt/$d/$(basename "$f")
	# mount the file (making the directory path as needed)
	gksudo -m "$m" "mkdir '$s' -p"
	gksudo -m "$m" "mount -v -o loop,uid=$(id -u) -t squashfs '$f' '$s'" || dmesg | tail
done < $files

rm $files

exec 1<&- 2<&-

