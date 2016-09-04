What? (purpose)
===============

DocuWiki server

Note: it will be useful to install a DW plugin like https://www.dokuwiki.org/plugin:smtp to use our SMTP relay! :-)


Who? (dependencies)
===================

    links:
    - email-relay:email-relay


How? (usage)
============

docker-compose [up -d|stop|start] dokuwiki


Where? (volumes)
================

To save your blog data, mount volumes in
	/var/www/html/conf
	/var/www/html/lib/plugins
	/var/www/html/data

    volumes:
    - /srv/dokuwiki/acme-challenge/.well-known:/var/www/html/.well-known
    - /srv/dokuwiki/conf:/var/www/html/conf
    - /srv/dokuwiki/lib/plugins:/var/www/html/lib/plugins
    - /srv/dokuwiki/data:/var/www/html/data
    - /srv/logs/dokuwiki:/var/log


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
      - #DOKUWIKI_VERSION=2016-06-26a
      - DOKUWIKI_VERSION=latest

runtime
-------

(none)


Upgrading version
=================

DokuWiki: online upgrade before upgrading Docker image
	http://www.dokuwiki.org/plugin:upgrade
