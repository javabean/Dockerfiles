#!/bin/sh
set -e

# copy conf dirs to enable populating empty volumes (see restore_conf.sh)
rm -rf /owncloud-config.bak
cp -a /var/www/owncloud/config /owncloud-config.bak

rm -rf /owncloud-apps.bak
cp -a /var/www/owncloud/apps /owncloud-apps.bak
