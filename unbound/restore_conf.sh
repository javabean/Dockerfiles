#!/bin/sh
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# copy backup of conf dirs if mounted volume is empty
for d in /etc/unbound/unbound.conf.d /var/lib/unbound ; do
	# if [ ! "$(ls -U "${d}")" ]; then
	if ! ls -U "${d}"/* > /dev/null 2>&1; then
		cp -a "${d}.bak/." "${d}"/
	fi
done
