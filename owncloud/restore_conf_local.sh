#!/bin/sh
set -e

# copy backup of conf dirs if mounted volume is empty

# if [ ! "$(ls -A "${d}")" ]; then
if ! ls -A /var/www/owncloud/config/* > /dev/null 2>&1; then
	tar xzf /owncloud-config.tgz -C /var/www/owncloud
fi

# if [ ! "$(ls -A "${d}")" ]; then
if ! ls -A /var/www/owncloud/apps/* > /dev/null 2>&1; then
	tar xzf /owncloud-apps.tgz -C /var/www/owncloud
fi

if [ ! -z "${SERVER_NAME}" ]; then
	sed -i'' -e "s%^\(\s*\)#*\(.*\)__SERVER_NAME__\(.*\)$%\1\2${SERVER_NAME}\3%g" /etc/apache2/conf-enabled/owncloud.conf
fi
