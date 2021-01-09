#!/bin/sh
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# copy backup of conf dirs if mounted volume is empty

if [ ! -f /var/www/html/update.php ]; then
	#tar xzf /ttrss.tgz -C /var/www
	cp -a /usr/src/tt-rss/* /var/www/html/
	#cp -a /usr/src/tt-rss/.git* /var/www/html/
	mkdir -p /var/www/html/.well-known/acme-challenge
	chown -R www-data: /var/www/html/.well-known || true
fi

if [ ! -z "${SERVER_NAME:-}" ]; then
	sed -i'' -e "s%^\(\s*\)#*\(.*\)__SERVER_NAME__\(.*\)$%\1\2${SERVER_NAME}\3%g" /etc/apache2/conf-enabled/tt-rss.conf
fi

# The following heavily inspired by https://git.tt-rss.org/fox/ttrss-docker-compose

DST_DIR=/var/www/html

if [ ! -s "${DST_DIR}/config.php" ]; then
	SELF_URL_PATH=$(echo "${SELF_URL_PATH}" | sed -e 's/[\/&]/\\&/g')

	sed \
		-e "s/define('DB_TYPE'.*/define('DB_TYPE', '${DB_TYPE}');/" \
		-e "s/define('DB_HOST'.*/define('DB_HOST', '${DB_HOST}');/" \
		-e "s/define('DB_PORT'.*/define('DB_PORT', '${DB_PORT}');/" \
		-e "s/define('DB_USER'.*/define('DB_USER', '${DB_USER}');/" \
		-e "s/define('DB_NAME'.*/define('DB_NAME', '${DB_NAME}');/" \
		-e "s/define('DB_PASS'.*/define('DB_PASS', '${DB_PASS}');/" \
		-e "s/define('REG_NOTIFY_ADDRESS'.*/define('REG_NOTIFY_ADDRESS', '${REG_NOTIFY_ADDRESS:-}');/" \
		-e "s/define('SMTP_FROM_ADDRESS'.*/define('SMTP_FROM_ADDRESS', '${SMTP_FROM_ADDRESS:-}');/" \
		-e "s/define('CHECK_FOR_UPDATES'.*/define('CHECK_FOR_UPDATES', false);/" \
		-e "s/define('PLUGINS'.*/define('PLUGINS', 'auth_internal, mailer_smtp, data_migration, af_zz_noautoplay');/" \
		-e "s/define('SELF_URL_PATH'.*/define('SELF_URL_PATH','${SELF_URL_PATH}');/" \
		-e "s/define('LOG_DESTINATION'.*/define('LOG_DESTINATION', '');/" \
		< "${DST_DIR}/config.php-dist" > "${DST_DIR}/config.php"

	cat >> $DST_DIR/config.php << EOF
		// plugin: af_img_phash (optional)
//		define('IMG_HASH_SQL_FUNCTION', true);

		// plugin: mailer_smtp
		define('SMTP_SERVER', 'email-relay:25');
		// Hostname:port combination to send outgoing mail (i.e. localhost:25).
		// Blank - use system MTA.
	
		define('SMTP_LOGIN', '');
		define('SMTP_PASSWORD', '');
		// These two options enable SMTP authentication when sending
		// outgoing mail. Only used with SMTP_SERVER.
	
		define('SMTP_SECURE', '');
		// Used to select a secure SMTP connection. Allowed values: ssl, tls,
		// or empty.
	
		//define('SMTP_SKIP_CERT_CHECKS', false);
		// Accept all SSL certificates, use with caution.
	
		//define('SMTP_CA_FILE', '/path/to/ca.crt');
		// Use a custom CA certificate for SSL/TLS secure connections.
		// Only used if SMTP_SKIP_CERT_CHECKS is false.

		// Also change 'SMTP_FROM_NAME' and 'SMTP_FROM_ADDRESS' in config.php

		// plugin: nginx_xaccel
//		define('NGINX_XACCEL_PREFIX', '/tt-rss');
EOF

	chown www-data: "${DST_DIR}/config.php"
fi

/usr/local/bin/wait_for.sh mysqladmin --silent --wait=9 --connect_timeout 10 -h "${DB_HOST:-mysql}" -u "${DB_USER:-fox}" -p"${DB_PASS:-ttrss}" ping


#export PGPASSWORD="${DB_PASS}"
#PSQL="psql -q -h ${DB_HOST} -U ${DB_USER} ${DB_NAME}"
#
#${PSQL} -c "create extension if not exists pg_trgm"
#
#RESTORE_SCHEMA="${DST_DIR}/backups/restore-schema.sql.gz"
#
#if [ -r "${RESTORE_SCHEMA}" ]; then
#	zcat "${RESTORE_SCHEMA}" | ${PSQL}
#elif ! ${PSQL} -c 'select * from ttrss_version'; then
#	${PSQL} < "${DST_DIR}/schema/ttrss_schema_pgsql.sql"
#fi


MYSQL="mysql --batch --connect-timeout=30 -h ${DB_HOST} -u ${DB_USER} -p${DB_PASS}"

RESTORE_SCHEMA="${DST_DIR}/backups/restore-schema.sql.gz"

if [ -r "${RESTORE_SCHEMA}" ]; then
	zcat "${RESTORE_SCHEMA}" | ${MYSQL}
elif ! ( echo "USE \`${DB_NAME}\`;" && echo 'select * from ttrss_version;' ) |  ${MYSQL}; then
	( echo "USE \`${DB_NAME}\`;" && cat "${DST_DIR}/schema/ttrss_schema_mysql.sql" ) | ${MYSQL}
fi
