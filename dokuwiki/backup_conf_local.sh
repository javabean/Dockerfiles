#!/bin/sh
set -e

# copy conf dirs to enable populating empty volumes (see restore_conf.sh)

tar czf /var/www/data.tgz -C /var/www/html data
tar czf /var/www/conf.tgz -C /var/www/html conf
tar czf /var/www/lib-plugins.tgz -C /var/www/html/lib plugins
tar czf /var/www/lib-tpl.tgz -C /var/www/html/lib tpl
