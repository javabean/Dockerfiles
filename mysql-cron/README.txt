What? (purpose)
===============

MySQL server backup via cron job

To be used with https://hub.docker.com/_/mysql where the ${MYSQL_CRON_LABEL:-mysql-cron-backup} label is set


Who? (dependencies)
===================

(none)


How? (usage)
============

	docker-compose [up -d|stop|start] mysql-backup


Where? (volumes)
================

Will automatically backup the database every day in /srv if the file /srv/dump.sql.gz exists

    volumes:
    - /srv/mysql/backup:/srv
    - /var/run/docker.sock:/var/run/docker.sock:ro


Where? (ports)
==============

(none)


Environment variables
=====================

build-time
----------

(none)

runtime
-------

    environment:
    - MYSQL_CRON_LABEL=mysql-cron-backup
    - MYSQL_ROOT_PASSWORD=


Upgrading version
=================

