#!/bin/sh
set -e

# copy backup of conf dirs if mounted volume is empty
for d in /etc/dnsmasq.d ; do
	# if [ ! "$(ls -A "${d}")" ]; then
	if ! ls -A "${d}"/* > /dev/null 2>&1; then
		cp -a "${d}.bak/." "${d}"/
	fi
done
