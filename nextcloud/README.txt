What? (purpose)
===============

Nextloud server, same as official image with some tweaks.  
After 1st startup, comment out database environnement variables to unable seamless container re-creation.


Who? (dependencies)
===================

    links:
    - mysql:mysql
    #- memcached-nextcloud:memcached
    - redis-nextcloud:redis
    - email-relay:email-relay


How? (usage)
============

	docker-compose [up -d|stop|start] nextcloud


Where? (volumes)
================

Mount configuration folder in /var/www/nextcloud/config  
Mount data into /srv/nextcloud/data (nextcloud data) and /srv/nextcloud/backup (SQLite backups)

Will automatically backup SQLite DB daily if file /srv/nextcloud/backup/nextcloud-dump.sql.gz exists

    volumes:
    - /srv/nextcloud/acme-challenge/.well-known:/var/www/nextcloud/.well-known
    - /opt/nextcloud/config:/var/www/nextcloud/config
    - /opt/nextcloud/apps:/var/www/nextcloud/custom_apps
    - /opt/nextcloud/themes:/var/www/nextcloud/themes
    - /srv/nextcloud/data:/srv/nextcloud/data


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
      - DOCKER_FROM_TAG=production-apache

runtime
-------

See https://github.com/nextcloud/docker/blob/master/README.md  
Also: ENABLE_CRON=1 to launch an in-container cron daemon


Upgrading version
=================

