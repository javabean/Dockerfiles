What? (purpose)
===============

Front httpd server, used to serve static files (including WebDAV)


Who? (dependencies)
===================


How? (usage)
============

	docker-compose [up -d|stop|start] http-static


Where? (volumes)
================

Put all extra configuration in:
/opt/http-static/mods-enabled/*.conf
/opt/http-static/conf-enabled/*.conf
/opt/http-static/sites-enabled/*.conf

    volumes:
    #- /opt/http-static/mods-available:/opt/http-static/mods-available:ro
    - /opt/http-static/mods-enabled:/opt/http-static/mods-enabled:ro
    #- /opt/http-static/conf-available:/opt/http-static/conf-available:ro
    - /opt/http-static/conf-enabled:/opt/http-static/conf-enabled:ro
    - /opt/http-static/conf-include:/opt/http-static/conf-include:ro
    #- /opt/http-static/sites-available:/opt/http-static/sites-available:ro
    - /opt/http-static/sites-enabled:/opt/http-static/sites-enabled:ro
    - /opt/http-static/tls:/opt/http-static/tls:ro
    #- /opt/letsencrypt:/opt/http-static/tls:ro
    - /srv/http-static:/var/www:ro
    - /srv/logs/http-static:/var/log


Where? (ports)
==============

    ports:
    - "80:80"
    #- "443:443"


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

