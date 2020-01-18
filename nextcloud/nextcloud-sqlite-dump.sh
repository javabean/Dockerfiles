#!/bin/sh
set -eu
(set -o | grep -q pipefail) && set -o pipefail
(set -o | grep -q posix) && set -o posix
#shopt -s failglob
#set -x

# This in case logrotate isn't available (no backup file rotation, &c.)

type sqlite3 > /dev/null 2>&1 || exit 0
[ -e /srv/nextcloud/data/nextcloud.db ] || exit 0

[ -f /etc/container_environment.sh ] && . /etc/container_environment.sh
sqlite3 /srv/nextcloud/data/nextcloud.db .dump | gzip > /srv/nextcloud/backup/nextcloud-dump.sql.gz || true
