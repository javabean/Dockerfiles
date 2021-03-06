#!/bin/sh
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# copy backup of conf dirs if mounted volume is empty
for d in /etc/apache2/conf-available /etc/apache2/conf-enabled \
/etc/apache2/mods-available /etc/apache2/mods-enabled \
/etc/apache2/sites-available /etc/apache2/sites-enabled ; do
	if [ -z "$(ls -AUq -- "${d}" 2> /dev/null)" ]; then
		cp -a "${d}.bak/." "${d}"/
	fi
done

if [ -x /usr/local/bin/restore_conf_local.sh ]; then
	/usr/local/bin/restore_conf_local.sh
fi
