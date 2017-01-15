What? (purpose)
===============

Simple internal Redis server
with --maxmemory-policy noeviction option and 200 maxclients

Do not put as-is on an external network since there is no ACL in configuration!


Who? (dependencies)
===================

(none)


How? (usage)
============

	docker-compose [up -d|stop|start] redis


Where? (volumes)
================

Mount /var/lib/redis/ if you wish to use persistence feature, or run this image r/o:

    volumes:
    - /srv/redis:/var/lib/redis
    #- /srv/logs/redis:/var/log


Where? (ports)
==============

    expose:
    - "6379"


Environment variables
=====================

build-time
----------

(none)

runtime
-------

Set required memory size in $MAX_MEMORY environment (defaults to "64mb")

    environment:
    - MAX_MEMORY=64mb


Upgrading version
=================

