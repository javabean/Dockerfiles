#!/bin/sh
set -eu
#set -o pipefail -o posix
#shopt -s failglob
#set -x

# copy backup of conf dirs if mounted volume is empty
for d in /etc/unbound/unbound.conf.d /var/lib/unbound ; do
	# if [ ! "$(ls -A "${d}")" ]; then
	if ! ls -A "${d}"/* > /dev/null 2>&1; then
		cp -a "${d}.bak/." "${d}"/
	fi
done
