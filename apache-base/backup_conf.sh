#!/bin/sh
set -e

# copy conf dirs to enable populating empty volumes (see restore_conf.sh)
for d in /etc/apache2/conf-available /etc/apache2/conf-enabled \
/etc/apache2/mods-available /etc/apache2/mods-enabled \
/etc/apache2/sites-available /etc/apache2/sites-enabled ; do
	rm -rf "${d}.bak"
	cp -a "${d}" "${d}.bak"
done

if [ -x /usr/local/bin/backup_conf_local.sh ]; then
	/usr/local/bin/backup_conf_local.sh
fi
