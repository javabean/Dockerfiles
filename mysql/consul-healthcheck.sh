#!/bin/sh
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# mysqld process
num_processes=`pgrep -cx mysqld`
if [ "$num_processes" -eq 0 ]; then
	echo "No mysqld process!"
	exit 2
fi

# mysqladmin ping
MYSQL_RANDOM_ROOT_PASSWORD=${MYSQL_RANDOM_ROOT_PASSWORD:-}
MYSQL_USER=${MYSQL_USER:-}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-}
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-}
if [ "$MYSQL_RANDOM_ROOT_PASSWORD" ] && [ -z "$MYSQL_USER" ] && [ -z "$MYSQL_PASSWORD" ]; then
	# there's no way we can guess what the random MySQL password was
	echo >&2 'healthcheck error: cannot determine random root password (and MYSQL_USER and MYSQL_PASSWORD were not set)'
	exit 0
fi

# The return status from mysqladmin is 0 if the server is running, 1 if it is not.
# This is 0 even in case of an error such as Access denied, because this means that the server is running but refused the connection, which is different from the server not running.
host="127.0.0.1"
user="${MYSQL_USER:-root}"
MYSQL_PWD="${MYSQL_PASSWORD:-$MYSQL_ROOT_PASSWORD}"
mysqladmin --connect_timeout 1 -h "$host" -u "$user" -p"${MYSQL_PWD}" ping || exit 2

exit 0
