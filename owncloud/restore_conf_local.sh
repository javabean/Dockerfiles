#!/bin/sh
set -e

# copy backup of conf dirs if mounted volume is empty

# if [ ! "$(ls -A "${d}")" ]; then
if ! ls -A /var/www/owncloud/config/* > /dev/null 2>&1; then
	cp -a /owncloud-config.bak/. /var/www/owncloud/config/
fi

# if [ ! "$(ls -A "${d}")" ]; then
if ! ls -A /var/www/owncloud/apps/* > /dev/null 2>&1; then
	cp -a /owncloud-apps.bak/. /var/www/owncloud/apps/
fi
