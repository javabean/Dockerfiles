What? (purpose)
===============

[TiddlyWiki](http://tiddlywiki.com) server

Running user is www-data


Who? (dependencies)
===================

(none)


How? (usage)
============

	docker-compose [up -d|stop|start] tiddlywiki


Where? (volumes)
================

    volumes:
    - /srv/tiddlywiki:/srv


Where? (ports)
==============

    expose:
    - "8080"


Environment variables
=====================

build-time
----------

(none)

runtime
-------

    environment:
    - WIKI_FOLDER=wiki
    - PORT=8080
    - USERNAME=
    - PASSWORD=
    - PATHPREFIX=


Upgrading version
=================

`npm update -g tiddlywiki`  
Don't forget to update your installed plugins, themes & languages!
