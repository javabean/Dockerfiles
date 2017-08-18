#!/bin/sh
set -eu
#set -x

print_usage() {
	cat << EOT
Usage
    ${0##*/} -f old_fqdn -r new_fqdn
    Changes a WordPress instance domain name.
    E.g.: sudo -u www-data ${0##*/} -f "beta.example.net" -r "www.example.net"
EOT
}

main() {
	local BACKUP_DIR=${BACKUP_DIR:-"/tmp"}
	local BACKUP_SUFFIX="`date +%Y%m%d-%H%M%S`"
	local URL_FIND=${URL_FIND:-}
	local URL_REPLACE=${URL_REPLACE:-}
	
	# Options
	while getopts "b:f:r:" option; do
		case "$option" in
			b) BACKUP_DIR=$OPTARG ;;
			f) URL_FIND=$OPTARG ;;
			r) URL_REPLACE=$OPTARG ;;
			*) print_usage; exit 1 ;;
		esac
	done
	shift $((OPTIND - 1))  # Shift off the options and optional --
	
	if [ -z "${BACKUP_DIR}" -o -z "${URL_FIND}" -o -z "${URL_REPLACE}" ]; then
		print_usage
		exit 1
	fi
	if echo "${URL_FIND}${URL_REPLACE}" | grep -q '[^-a-zA_Z0-9.]'; then
		echo "Aborting: illegal char(s) in ${URL_FIND} or ${URL_REPLACE}"
		exit 1
	fi

	local DB_HOST=$(wp config get --constant=DB_HOST)
	local DB_USER=$(wp config get --constant=DB_USER)
	local DB_PASSWORD=$(wp config get --constant=DB_PASSWORD)
	local DB_NAME=$(wp config get --constant=DB_NAME)
	local DB_PREFIX=$(wp config get --global=table_prefix)

	if [ -z "$DB_HOST" -o -z "$DB_USER" -o -z "${DB_NAME}" -o -z "${DB_PREFIX}" ]; then
		echo "Can not read database information from `wp config path`: aborting!"
		exit 1
	fi

	if ! wp plugin is-installed wp-migrate-db ; then
		echo "Installing wp-migrate-db..."
		wp plugin install wp-migrate-db --activate --activate-network
	fi

	local DB_DEST_BACKUP_FILE="${BACKUP_DIR}/wp-db-backup_${BACKUP_SUFFIX}.sql.gz"
#	local DB_DUMP_FILE="${BACKUP_DIR}/wp-db.sql.gz"

	echo "Backing up WordPress database to ${DB_DEST_BACKUP_FILE}..."
	#mysqldump -u "${DB_USER}" -p"${DB_PASSWORD}" --single-transaction --databases "${DB_NAME}" | gzip > "${DB_DEST_BACKUP_FILE}"
	wp migratedb export "${DB_DEST_BACKUP_FILE}" --skip-replace-guids --exclude-spam --gzip-file

	echo "Converting WordPress database -- ${URL_FIND} -> ${URL_REPLACE}"
	wp migratedb find-replace --find="//${URL_FIND},%2F%2F${URL_FIND},%252F%252F${URL_FIND}" --replace="//${URL_REPLACE},%2F%2F${URL_REPLACE},%252F%252F${URL_REPLACE}" --skip-replace-guids --exclude-spam

#	echo "Dumping and converting WordPress database into ${DB_DUMP_FILE} -- ${URL_FIND} -> ${URL_REPLACE}"
#	wp migratedb export "${DB_DUMP_FILE}" --find="//${URL_FIND},%2F%2F${URL_FIND},%252F%252F${URL_FIND}" --replace="//${URL_REPLACE},%2F%2F${URL_REPLACE},%252F%252F${URL_REPLACE}" --skip-replace-guids --exclude-spam --gzip-file
#
#	echo "Importing database from ${DB_DUMP_FILE} into ${DB_USER}@${DB_HOST}:${DB_NAME}..."
#	# wait up to 1.5 minutes for the remote DB to be available (use case: startup)
#	#mysqladmin --silent --no-beep --wait=9 --connect_timeout 10 -h "${MYSQL_HOST}" -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" ping
#	( echo "USE \`${DB_NAME}\`;" && zcat "${DB_DUMP_FILE}" ) | mysql --batch --connect-timeout=30 -u "$DB_USER" -p"$DB_PASSWORD" -h "$DB_HOST"
	( echo "USE \`${DB_NAME}\`; update ${DB_PREFIX}usermeta set meta_value='${URL_REPLACE}' where meta_key='source_domain' and meta_value='${URL_FIND}'" ) | mysql --batch --connect-timeout=30 -u "${DB_USER}" -p"${DB_PASSWORD}" -h "${DB_HOST}"

	echo "Flushing WordPress caches..."
	wp cache flush
	wp total-cache flush all || true
}
main "$@"
