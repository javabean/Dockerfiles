#!/bin/sh
set -e

# copy conf dirs to enable populating empty volumes (see restore_conf.sh)
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
	rm -rf "/var/www/html/${d}.bak"
	cp -a "/var/www/html/${d}" "/var/www/html/${d}.bak"
done

if [ -f "/var/www/html/configuration.php" ]; then
	cp -a "/var/www/html/configuration.php" "/var/www/html/configuration.php.bak"
fi
