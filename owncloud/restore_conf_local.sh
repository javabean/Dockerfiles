#!/bin/sh
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# copy backup of conf dirs if mounted volume is empty

if [ -z "$(ls -AUq -- /var/www/owncloud/config/ 2> /dev/null)" ]; then
	tar xzf /owncloud-config.tgz -C /var/www/owncloud
fi

if [ -z "$(ls -AUq -- /var/www/owncloud/apps/ 2> /dev/null)" ]; then
	tar xzf /owncloud-apps.tgz -C /var/www/owncloud
fi

if [ ! -z "${SERVER_NAME}" ]; then
	sed -i'' -e "s%^\(\s*\)#*\(.*\)__SERVER_NAME__\(.*\)$%\1\2${SERVER_NAME}\3%g" /etc/apache2/conf-enabled/owncloud.conf
fi

#/usr/local/bin/wait_for.sh mysqladmin --silent --wait=9 --connect_timeout 10 -h "${OC_DB_HOST:-mysql}" -u "${OC_DB_USER:-owncloud}" -p"${OC_DB_PASSWORD:-owncloud}" ping
