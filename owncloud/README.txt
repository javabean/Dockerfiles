What? (purpose)
===============

OwnCloud server


Who? (dependencies)
===================

    links:
    - mysql:mysql
    #- memcached-owncloud:memcached
    - redis-owncloud:redis
    - email-relay:email-relay


How? (usage)
============

	docker-compose [up -d|stop|start] owncloud

Exposes APC cache statistics on URL `/apc.php`


Where? (volumes)
================

Mount configuration folder in /var/www/html/config  
Mount data into /srv/owncloud/data (owncloud data) and /srv/owncloud/backup (SQLite backups)

Will automatically backup SQLite DB daily if file /srv/owncloud/backup/owncloud-dump.sql.gz exists

    volumes:
    - /opt/owncloud/config:/var/www/html/config
    - /opt/owncloud/apps:/var/www/html/apps-external
    - /opt/owncloud/ip-restriction.conf:/etc/apache2/conf-enabled/ip-restriction.conf:ro
    - /srv/owncloud:/srv/owncloud
    - /srv/logs/owncloud:/var/log


Where? (ports)
==============

    expose:
    - "80"
    - "443"


Environment variables
=====================

build-time
----------

    build:
      args:
      - OWNCLOUD_VERSION=stable

runtime
-------

(none)


Upgrading version
=================

