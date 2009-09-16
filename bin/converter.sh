#!/bin/bash

INPUT=${1}
OUTPUT=${2}

ffmpeg -y -i "${INPUT}" -vcodec h264 -b 1000000 -acodec libfaac -ar 48000 -ab 160 -f mov "${OUTPUT}"
