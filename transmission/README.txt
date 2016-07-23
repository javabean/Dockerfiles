What? (purpose)
===============

Transmission-based bittorrent server

Do not put as-is on an external network since there is no ACL!  
(You will need to shut down the container and edit settings.json should you want to add ACL:
https://trac.transmissionbt.com/wiki/EditConfigFiles)


Who? (dependencies)
===================

(none)


How? (usage)
============

docker-compose [up -d|stop|start] transmission


Where? (volumes)
================

    volumes:
    - /srv/transmission:/var/lib/transmission-daemon


Where? (ports)
==============

    expose:
    - "9091"
    ports:
    - "51413:51413/tcp"
    - "51413:51413/udp"


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

