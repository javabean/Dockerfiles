#!/bin/sh
set -e

# copy conf dirs to enable populating empty volumes (see restore_conf.sh)

tar czf /var/www/html.tgz -C /var/www html
