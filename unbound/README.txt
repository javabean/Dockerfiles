What? (purpose)
===============

Unbound is our external DNS gateway, with ACL


Who? (dependencies)
===================

    depends_on:
    - dnsmasq
    dns:
    - 172.31.53.53


How? (usage)
============

	docker-compose [up -d|stop|start] unbound

Put configuration files in /etc/unbound/unbound.conf.d/*.conf (mount it as a volume!)  
Make sure to specify in a configuration file

	server:
		do-daemonize: no


Where? (volumes)
================

    volumes:
    - /opt/unbound:/etc/unbound/unbound.conf.d:ro
    #- /srv/logs/unbound:/var/log


Where? (ports)
==============

    ports:
    - "192.0.2.10:53:53/tcp"
    - "192.0.2.10:53:53/udp"


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

