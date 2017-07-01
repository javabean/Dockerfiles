#!/bin/bash
#set -u
set -e -o pipefail -o posix
#shopt -s failglob
#set -x

# copy backup of conf dirs if mounted volume is empty

# if [ ! "$(ls -U "/var/www/html/")" ]; then
if ! ls -U /var/www/html/* > /dev/null 2>&1; then
	tar xzf /var/www/html.tgz -C /var/www
fi

# now that we're definitely done writing configuration, let's clear out the relevant envrionment variables (so that stray "phpinfo()" calls don't leak secrets from our code)
for e in "${envs[@]}"; do
	unset "$e"
done

#/usr/local/bin/wait_for.sh mysqladmin --silent --wait=9 --connect_timeout 10 -h "${JOOMLA_DB_HOST:-mysql}" -u "${JOOMLA_DB_USER:-joomla}" -p"${JOOMLA_DB_PASSWORD:-joomla}" ping
