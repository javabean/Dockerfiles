#!/bin/sh
set -eu
#set -o pipefail -o posix
#shopt -s failglob
#set -x

# copy conf dirs to enable populating empty volumes (see restore_conf.sh)
for d in /etc/dnsmasq.d /opt/dnsmasq ; do
	rm -rf "${d}.bak"
	cp -a "${d}" "${d}.bak"
done
