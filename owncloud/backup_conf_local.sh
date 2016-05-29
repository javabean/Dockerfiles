#!/bin/sh
set -e

# copy conf dirs to enable populating empty volumes (see restore_conf.sh)
tar czf /owncloud-config.tgz -C /var/www/owncloud config
tar czf /owncloud-apps.tgz -C /var/www/owncloud apps
