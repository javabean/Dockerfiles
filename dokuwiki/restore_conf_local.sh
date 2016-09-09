#!/bin/bash
set -e

# copy backup of conf dirs if mounted volume is empty

for d in data conf; do
	# if [ ! "$(ls -A "/var/www/html/${d}")" ]; then
	if ! ls -A "/var/www/html/${d}"/* > /dev/null 2>&1; then
		tar xzf /var/www/${d}.tgz -C /var/www/html
	fi
done

# if [ ! "$(ls -A "/var/www/html/${d}")" ]; then
if ! ls -A "/var/www/html/lib/plugins"/* > /dev/null 2>&1; then
	tar xzf /var/www/lib-plugins.tgz -C /var/www/html/lib
fi

# if [ ! "$(ls -A "/var/www/html/${d}")" ]; then
if ! ls -A "/var/www/html/lib/tpl"/* > /dev/null 2>&1; then
	tar xzf /var/www/lib-tpl.tgz -C /var/www/html/lib
fi
