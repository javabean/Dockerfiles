What? (purpose)
===============

Ziproxy server  
Used for internal http proxy only, re-compressing jpeg images on-the-fly.

WARNING: never, /never/, *never* put this image directly accessible from Internet!  
(even with auth, it is not secure enough!)


Who? (dependencies)
===================

(none)


How? (usage)
============

docker-compose [up -d|stop|start] web-accelerator


Where? (volumes)
================

#    volumes:
#    - /srv/logs/ziproxy:/var/log


Where? (ports)
==============

    expose:
    - "3128"

    networks:
      vpn:
        ipv4_address: 172.31.31.28


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
