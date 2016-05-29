#!/bin/sh
set -e

# copy conf dirs to enable populating empty volumes (see restore_conf.sh)
for d in /etc/unbound/unbound.conf.d ; do
	rm -rf "${d}.bak"
	cp -a "${d}" "${d}.bak"
done
