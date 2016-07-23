What? (purpose)
===============

netdata server (https://github.com/firehol/netdata/)


Who? (dependencies)
===================

(none)


How? (usage)
============

docker-compose [up -d|stop|start] netdata


Where? (volumes)
================

    volumes:
    - /proc:/mnt/proc:ro
    - /sys:/mnt/sys:ro
    - /opt/netdata:/etc/netdata:ro
    #- /srv/logs/netdata:/var/log


Where? (ports)
==============

    expose:
    - "19999"


Environment variables
=====================

build-time
----------

(none)

runtime
-------

(none)


Upgrading version
=================

