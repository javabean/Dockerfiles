#!/bin/sh
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# copy conf dirs to enable populating empty volumes (see restore_conf.sh)
for d in override \
mails  img  modules \
download upload \
translations \
config ; do
	rm -rf "/var/www/html/${d}.bak"
	cp -a "/var/www/html/${d}" "/var/www/html/${d}.bak"
done

if [ -f "/var/www/html/.htaccess" ]; then
	cp -a "/var/www/html/.htaccess" "/var/www/html/.htaccess.bak"
fi
