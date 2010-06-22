#!/bin/bash

# Umm, so I forget what this does...
# but I *think* it converts video so it's playable on xbox360


main () {
  local i= o=
  while getopts :i:o: Opt; do
    case $Opt in
      i) i=$OPTARG;; # input file
      o) o=$OPTARG;; # output file
    esac
  done
  

  ffmpeg -y -i "$i" -vcodec h264 -b 1000000 -acodec libfaac -ar 48000 -ab 160 -f mov "$o"


}

main $@

