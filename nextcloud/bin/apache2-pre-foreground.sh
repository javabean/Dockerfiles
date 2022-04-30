#!/bin/sh
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# Backup version.php to enable automatic upgrade
# (the backup is symlinked in Dockerfile)
if [ ! -f /var/www/html/config/version.php ] || ! diff -qN /var/www/html/version.php /var/www/html/config/version.php > /dev/null 2>&1 ; then
	cp -a /var/www/html/version.php /var/www/html/config/version.php
fi

rm -f ${PHP_INI_DIR}/conf.d/zz_newrelic_tmp.ini

#exec apache2 -D FOREGROUND -k start
exec apache2-foreground "$@"
