#!/bin/bash
#set -u
set -e -o pipefail -o posix
#shopt -s failglob
#set -x

/usr/local/bin/wait_for.sh mysqladmin --silent --wait=9 --connect_timeout 10 -h "${DB_SERVER:-mysql}" -u "${DB_USER:-prestashop}" -p"${DB_PASSWD:-prestashop}" ping

# copy backup of conf dirs if mounted volume is empty

for d in override \
mails  img  modules \
download upload \
translations \
config ; do

	# if [ ! "$(ls -U "/var/www/html/${d}")" ]; then
	if ! ls -U "/var/www/html/${d}"/* > /dev/null 2>&1; then
		cp -a "/var/www/html/${d}.bak/." "/var/www/html/${d}"/
	fi
done

if [ ! -f "/var/www/html/.htaccess" ] && [ -f "/var/www/html/.htaccess.bak" ]; then
	cp -a "/var/www/html/.htaccess.bak" "/var/www/html/.htaccess"
fi

for f in config.inc.php defines.inc.php smarty.config.inc.php ; do
	if [ ! -f "/var/www/html/config/${f}" ] && [ -f "/var/www/html/config.bak/${f}" ]; then
		cp -a "/var/www/html/config.bak/${f}" "/var/www/html/config/${f}"
	fi
done


if [ ! -z "$PS_FOLDER_INSTALL" ] && [ -d "/var/www/html/install" -a "$PS_FOLDER_INSTALL" != "install" ]; then
	echo "\n* Renaming \"install\" folder as \"$PS_FOLDER_INSTALL\"...";
	mv /var/www/html/install "/var/www/html/$PS_FOLDER_INSTALL"
fi

if [ ! -z "$PS_FOLDER_ADMIN" ] && [ -d "/var/www/html/admin" -a "$PS_FOLDER_ADMIN" != "admin" ]; then
	echo "\n* Renaming \"admin\" folder as \"$PS_FOLDER_ADMIN\"...";
	mv /var/www/html/admin "/var/www/html/$PS_FOLDER_ADMIN"
fi

# First run
if [ ! -f /var/www/html/config/settings.inc.php  ]; then
	if [ $PS_DEV_MODE -ne 0 ]; then
		echo "\n* Enabling DEV mode...";
		sed -ie "s/define('_PS_MODE_DEV_', false);/define('_PS_MODE_DEV_',\ true);/g" /var/www/html/config/defines.inc.php
	fi

	if [ $PS_HOST_MODE -ne 0 ]; then
		echo "\n* Enabling HOST mode...";
		echo "define('_PS_HOST_MODE_', true);" >> /var/www/html/config/defines.inc.php
	fi

	#if [ $PS_HANDLE_DYNAMIC_DOMAIN = 0 ]; then
	#	rm /var/www/html/docker_updt_ps_domains.php
	#else
	#	sed -ie "s/DirectoryIndex\ index.php\ index.html/DirectoryIndex\ docker_updt_ps_domains.php\ index.php\ index.html/g" $APACHE_CONFDIR/conf-available/docker-php.conf
	#fi

	if [ $PS_INSTALL_AUTO = 1 ]; then
		echo "\n* Installing PrestaShop, this may take a while...";

		php "/var/www/html/$PS_FOLDER_INSTALL/index_cli.php" \
			--step="${PS_STEP:-all}" \
			--language="${PS_LANGUAGE:-en}" --country="${PS_COUNTRY:-gb}" --all_languages="${PS_ALL_LANGUAGES:-0}" \
			--timezone="${PS_TIMEZONE:-`date +%Z`}" \
			--base_uri="${PS_BASE_URI:-/}" --domain="${PS_DOMAIN:-`hostname -i`}" \
			--db_server="${DB_SERVER:-localhost}" --db_user="${DB_USER:-root}" --db_password="${DB_PASSWD:-}" --db_name="${DB_NAME:-prestashop}" \
			--db_clear="${DB_CLEAR:-1}" --db_create="${DB_CREATE:-0}" \
			--prefix="${DB_PREFIX:-ps_}" --engine="${DB_ENGINE:-InnoDB}" \
			--name="${PS_NAME:-PrestaShop}" --activity="${PS_ACTIVITY:-0}" \
			--firstname="${ADMIN_FIRST_NAME:-John}" --lastname="${ADMIN_LAST_NAME:-Doe}" --password="${ADMIN_PASSWD:-0123456789}" --email="${ADMIN_MAIL:-pub@prestashop.com}" \
			--license="${PS_LICENSE:-0}" --newsletter="${ADMIN_NEWSLETTER:-0}" --send_email="${ADMIN_SEND_EMAIL:-0}"

		rm -r "/var/www/html/$PS_FOLDER_INSTALL"
	fi
fi

# now that we're definitely done writing configuration, let's clear out the relevant envrionment variables (so that stray "phpinfo()" calls don't leak secrets from our code)
for e in "${envs[@]}"; do
	unset "$e"
done
