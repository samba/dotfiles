#!/bin/bash


function ddwatch () {
# seconds to wait before checking 'dd' status
waitTime=10

dd $@ &
p=$!

while ps $p >/dev/null; do
	kill -USR1 ${p}
	sleep ${waitTime}
	clear
done

wait

}
