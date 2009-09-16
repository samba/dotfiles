#!/bin/sh

MY_IP=$(wget -O - http://checkip.dyndns.com/ 2>/dev/null | grep -oE '([0-9]+[\.]?){4}')

printf "export MY_IP='%s'\n" "$MY_IP"
