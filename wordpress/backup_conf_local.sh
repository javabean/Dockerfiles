#!/bin/sh
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# copy conf dirs to enable populating empty volumes (see restore_conf.sh)

tar czf /var/www/wp-content.tgz -C /var/www/html wp-content
[ -d /var/www/html/wp-includes/languages ] && tar czf /var/www/wp-includes-languages.tgz -C /var/www/html wp-includes/languages

for f in wp-config.php .htaccess robots.txt ; do
	if [ -f "/var/www/html/${f}" ]; then
		cp -a "/var/www/html/${f}" "/var/www/html/${f}.bak"
	fi
done
