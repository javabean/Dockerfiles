What? (purpose)
===============

Joomla docker container


Who? (dependencies)
===================

    links:
    - mysql:mysql
#    - memcached-joomla:memcached
    - email-relay:email-relay


How? (usage)
============

docker-compose [up -d|stop|start] joomla


Where? (volumes)
================

    volumes:
    - /srv/logs/joomla:/var/log
    - /srv/joomla:/var/www/html


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
      - JOOMLA_VERSION=3.4.8

runtime
-------

(none)


Upgrading version
=================

Online upgrade before upgrading Docker image
	https://docs.joomla.org/Portal:Upgrading_Versions
