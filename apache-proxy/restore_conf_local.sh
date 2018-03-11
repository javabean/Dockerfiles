#!/bin/sh
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# copy backup of conf dirs if mounted volume is empty

# if [ ! "$(ls -U "${d}")" ]; then
if ! ls -U /var/www/* > /dev/null 2>&1; then
	cp -a /var/www.bak/. /var/www/
fi
