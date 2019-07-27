#!/bin/sh
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# Wait until dependencies are up and running
if [ -x /usr/local/bin/wait_for.sh ]; then
	if [ -n "${MYSQL_HOST}" && -n "${MYSQL_USER}" && -n "${MYSQL_PASSWORD}" ]; then
		/usr/local/bin/wait_for.sh mysqladmin --silent --wait=9 --connect_timeout 10 -h "${MYSQL_HOST:-mysql}" -u "${MYSQL_USER:-nextcloud}" -p"${MYSQL_PASSWORD:-nextcloud}" ping
	elif [ -n "${POSTGRES_HOST}" && -n "${POSTGRES_USER}" && -n "${POSTGRES_PASSWORD}" ]; then
		# TODO
		:
	fi
	if [ -n "${REDIS_HOST}" && -n "${REDIS_HOST_PORT:-6379}" ]; then
		# TODO
		:
	fi
fi

# Apache gets grumpy about PID files pre-existing
rm -f /usr/local/apache2/logs/httpd.pid ${APACHE_RUN_DIR:-/var/run/apache2}/apache2.pid
# ssl_scache shouldn't be here if we're just starting up.
# (this is bad if there are several apache2 instances running)
rm -f ${APACHE_RUN_DIR:-/var/run/apache2}/*ssl_scache*

# Backup version.php to enable automatic upgrade
# (the backup is symlinked in Dockerfile)
if [ ! -f /var/www/html/config/version.php ] || ! diff -qN /var/www/html/version.php /var/www/html/config/version.php > /dev/null 2>&1 ; then
	cp -a /var/www/html/version.php /var/www/html/config/version.php
fi

# Launch cron in background. Poor man's solution...
if [ -n "${ENABLE_CRON}" ]; then
	busybox crond -b -l 8 -L /dev/stdout
fi

#exec apache2 -D FOREGROUND -k start
exec apache2-foreground
