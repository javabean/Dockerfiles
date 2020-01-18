What? (purpose)
===============

Tiny Tiny RSS server


Who? (dependencies)
===================

    links:
    - mysql:mysql
    - email-relay:email-relay


How? (usage)
============

	docker-compose [up -d|stop|start] tt-rss


Where? (volumes)
================

(none)  
Official plugins are already installed in the container.  
Data is in database.


Where? (ports)
==============

    expose:
    - "80"


Environment variables
=====================

build-time
----------

(none)

runtime
-------

    environment:
    - DB_TYPE=mysql
    - DB_HOST=mysql
    - DB_PORT=3306
    - DB_NAME=fox
    - DB_USER=fox
    - DB_PASS=
    - SELF_URL_PATH=https://ttrss.example.net
    - REG_NOTIFY_ADDRESS=user@your.domain.dom
    - SMTP_FROM_ADDRESS=noreply@your.domain.dom


Upgrading version
=================
