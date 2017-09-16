#!/bin/sh
set -eu
#set -o pipefail -o posix
#shopt -s failglob
#set -x

# copy backup of conf dirs if mounted volume is empty
for d in /etc/dnsmasq.d /opt/dnsmasq ; do
	# if [ ! "$(ls -U "${d}")" ]; then
	if ! ls -U "${d}"/* > /dev/null 2>&1; then
		cp -a "${d}.bak/." "${d}"/
	fi
done
