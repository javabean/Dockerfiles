#!/bin/sh
set -e

# copy backup of conf dirs if mounted volume is empty

# if [ ! "$(ls -U "/var/www/html/")" ]; then
if ! ls -U /var/www/html/* > /dev/null 2>&1; then
	tar xzf /var/www/html.tgz -C /var/www
fi
