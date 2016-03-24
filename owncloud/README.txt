OwnCloud server

Mount configuration folder in /var/www/owncloud/config
Mount data into /srv/owncloud/data (owncloud data) and /srv/owncloud/backup (SQLite backups)

Will automatically backup SQLite DB daily if file /srv/owncloud/backup/owncloud-dump.sql.gz exists

Exposes APC cache statistics on URL "/apc.php"
