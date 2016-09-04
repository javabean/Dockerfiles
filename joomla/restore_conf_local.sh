#!/bin/sh
set -e

# copy backup of conf dirs if mounted volume is empty

# if [ ! "$(ls -U "/var/www/html/")" ]; then
if ! ls -U /var/www/html/* > /dev/null 2>&1; then
	tar xzf /var/www/html.tgz -C /var/www
fi

#/usr/local/bin/wait_for.sh mysqladmin --silent --wait=9 --connect_timeout 10 -h "${JOOMLA_DB_HOST:-mysql}" -u "${JOOMLA_DB_USER:-joomla}" -p"${JOOMLA_DB_PASSWORD:-joomla}" ping
