What? (purpose)
===============

Front httpd server, used to proxy all other application servers (Tomcat, ownCloud, &c.)


Who? (dependencies)
===================

    links:
    - tomcat:tomcat
    - owncloud:owncloud
    - prestashop:prestashop
    - joomla:joomla


How? (usage)
============

docker-compose [up -d|stop|start] http-proxy


Where? (volumes)
================

Put all extra configuration in:
/opt/http-proxy/mods-enabled/*.conf
/opt/http-proxy/conf-enabled/*.conf
/opt/http-proxy/sites-enabled/*.conf

    volumes:
#    - /opt/http-proxy/mods-available:/opt/http-proxy/mods-available:ro
    - /opt/http-proxy/mods-enabled:/opt/http-proxy/mods-enabled:ro
#    - /opt/http-proxy/conf-available:/opt/http-proxy/conf-available:ro
    - /opt/http-proxy/conf-enabled:/opt/http-proxy/conf-enabled:ro
    - /opt/http-proxy/conf-include:/opt/http-proxy/conf-include:ro
#    - /opt/http-proxy/sites-available:/opt/http-proxy/sites-available:ro
    - /opt/http-proxy/sites-enabled:/opt/http-proxy/sites-enabled:ro
    - /opt/http-proxy/tls:/opt/http-proxy/tls:ro
#    - /opt/letsencrypt:/opt/http-proxy/tls:ro
    - /srv/http-proxy:/var/www:ro
    - /srv/logs/http-proxy:/var/log


Where? (ports)
==============

    ports:
    - "80:80"
    - "443:443"


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

