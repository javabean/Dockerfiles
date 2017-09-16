#!/bin/sh
set -eu
#set -o pipefail -o posix
#shopt -s failglob
#set -x

# copy backup of conf dirs if mounted volume is empty

# if [ ! "$(ls -U "${d}")" ]; then
if ! ls -U /var/www/* > /dev/null 2>&1; then
	cp -a /var/www.bak/. /var/www/
fi
