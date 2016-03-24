#!/bin/sh
set -e

# copy backup of conf dirs if mounted volume is empty

for d in \
administrator \
components \
images \
language \
libraries \
media \
modules \
plugins \
templates ; do
#logs \
#tmp \
	# if [ ! "$(ls -A "/var/www/html/${d}")" ]; then
	if ! ls -A "/var/www/html/${d}"/* > /dev/null 2>&1; then
		cp -a "/var/www/html/${d}.bak/." "/var/www/html/${d}"/
	fi
done

for f in configuration.php ; do
	if [ ! -f "/var/www/html/${f}" ] && [ -f "/var/www/html/${f}.bak" ] ; then
		cp -a "/var/www/html/${f}.bak" "/var/www/html/${f}"
	fi
done
