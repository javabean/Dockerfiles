#!/bin/sh
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# copy conf dirs to enable populating empty volumes (see restore_conf.sh)
for d in /etc/unbound/unbound.conf.d /var/lib/unbound ; do
	rm -rf "${d}.bak"
	cp -a "${d}" "${d}.bak"
done
