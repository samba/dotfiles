#!/bin/bash

s.audio.index () {
	for i in mp3 m4a wma; do
	find $@ -name *.$i | s.audio.$i.id
	done
}

s.audio.mp3.id () {
	while read i; do
		id3v2 $i ...
	done
}
