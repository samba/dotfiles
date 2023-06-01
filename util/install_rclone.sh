#!/bin/bash

case $(uname -s) in
    Linux)
        URL="https://downloads.rclone.org/rclone-current-linux-amd64.zip"
        ;;
    Darwin)
        URL="https://downloads.rclone.org/rclone-current-osx-amd64.zip"
        ;;
esac




FNAME=$(basename "$URL")

wget -O /tmp/${FNAME} -c ${URL}
sudo unzip -j /tmp/${FNAME} $(unzip -l /tmp/${FNAME} | grep -oE '([a-z0-9_\.-]+)/rclone$')  -d /usr/local/bin/


