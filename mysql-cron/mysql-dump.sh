#!/bin/sh
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# intented to be called by logrotate's prerotate
# see also automysqlbackup

main() {
	BACKUP_DIR="${BACKUP_DIR:-/srv}"

	/usr/local/bin/hc-ping.sh -s -u "${BACKUP_HC_PING_URL:-}"

	[ -s /etc/container_environment.sh ] && . /etc/container_environment.sh
	[ -s /run/environment ] && . /run/environment
	if [ -z "${MYSQL_ROOT_PASSWORD:-}" ]; then
		if [ -z "${MYSQL_USER:-}" ]; then
			CRON_MYSQL_USER="root"
			CRON_MYSQL_PASSWORD=""
		else
			CRON_MYSQL_USER="${MYSQL_USER}"
			CRON_MYSQL_PASSWORD="${MYSQL_PASSWORD:-}"
		fi
	else
		CRON_MYSQL_USER="root"
		CRON_MYSQL_PASSWORD="${MYSQL_ROOT_PASSWORD}"
	fi

	CONTAINERS=$(docker container ps --format '{{.Names}}' --filter "label=${MYSQL_CRON_LABEL:-mysql-cron-backup}" --filter="status=running" --filter="health=healthy")
	# Altough there is a loop, this utility is really intended for a single container...
	for CONTAINER_NAME in $CONTAINERS; do

		# TODO: MySQL 5.7: replace mysqldump with
		# 	nice mysqlpump -u "${CRON_MYSQL_USER}" -p"${CRON_MYSQL_PASSWORD}" --single-transaction [--users] --exclude-databases=mysql,test --compress-output=[LZ4|ZLIB] --default-parallelism=0 --skip-watch-progress [--all-databases | --databases db1 db2] > "${BACKUP_DIR}"/dump.sql.[lz4|zlib]
		# (to decompress:
		# 	lz4_decompress input_file output_file	|	lz4 -d input_file output_file
		# 	zlib_decompress input_file output_file	|	openssl zlib -d < input_file > output_file
		# )
		if [ -z "${MYSQL_DATABASE:-}" ]; then
			# dump all databases in a single file
			docker container exec "${CONTAINER_NAME}" nice mysqldump -u "${CRON_MYSQL_USER}" -p"${CRON_MYSQL_PASSWORD}" --single-transaction --all-databases | gzip > "${BACKUP_DIR}"/dump.sql.gz || true
			# dump all databases in separate files
			# mysqlshow -u "${CRON_MYSQL_USER}" -p"${CRON_MYSQL_PASSWORD}"
			for db in `docker container exec "${CONTAINER_NAME}" mysql -u "${CRON_MYSQL_USER}" -p"${CRON_MYSQL_PASSWORD}" --batch --silent --skip-column-names -e "show databases" | grep -v -i -e information_schema -e performance_schema -e ndbinfo -e sys -e mysql -e test | sed 's/\r$//'`; do
				docker container exec "${CONTAINER_NAME}" nice mysqldump -u "${CRON_MYSQL_USER}" -p"${CRON_MYSQL_PASSWORD}" --single-transaction --databases "${db}" | gzip > "${BACKUP_DIR}/dump-${db}.sql.gz" || true
			done
		else
			docker container exec "${CONTAINER_NAME}" nice mysqldump -u "${CRON_MYSQL_USER}" -p"${CRON_MYSQL_PASSWORD}" --single-transaction --databases "${MYSQL_DATABASE}" | gzip > "${BACKUP_DIR}"/dump.sql.gz || true
		fi

	done

	/usr/local/bin/hc-ping.sh -c -u "${BACKUP_HC_PING_URL:-}"
}
main "$@"
