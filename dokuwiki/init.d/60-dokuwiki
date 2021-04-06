#!/bin/sh
set -eu
#set -o pipefail -o posix
#shopt -s failglob
#set -x

# copy backup of conf dirs if mounted volume is empty

for d in data conf; do
	if [ -z "$(ls -AUq -- "/var/www/html/${d}" 2> /dev/null)" ]; then
		tar xzf /var/www/${d}.tgz -C /var/www/html
	fi
done

if [ -z "$(ls -AUq -- "/var/www/html/lib/plugins" 2> /dev/null)" ]; then
	tar xzf /var/www/lib-plugins.tgz -C /var/www/html/lib
fi

if [ -z "$(ls -AUq -- "/var/www/html/lib/tpl" 2> /dev/null)" ]; then
	tar xzf /var/www/lib-tpl.tgz -C /var/www/html/lib
fi
