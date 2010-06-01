#!/bin/sh

echo "Hi there!"

# By default, this script loads first, then the default (auto) scripts load.
# Set this to 1 (or higher) to prevent the default script from loading.
export SKIP_DEFAULT=0


sshtunnel -a & >/dev/null 2>/dev/null
