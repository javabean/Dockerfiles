What? (purpose)
===============

Simple Memcached server  
limits to 256 max simultaneous connections instead of default 1024

Do not put as-is on an external network since there is no ACL!


Who? (dependencies)
===================

(none)


How? (usage)
============

	docker-compose [up -d|stop|start] memcached

Some memcached utilities are in `/usr/local/bin/`


Where? (volumes)
================

    #volumes:
    #- /srv/logs/memcached:/var/log


Where? (ports)
==============

    expose:
    - "11211/tcp"
    - "11211/udp"


Environment variables
=====================

build-time
----------

(none)

runtime
-------

Set required memory size (in MB) in $MEM_SIZE environment (defaults to "64")

    environment:
    - MEM_SIZE=64


Upgrading version
=================

