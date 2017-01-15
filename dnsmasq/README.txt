What? (purpose)
===============

dnsmasq is our internal (since no ACL) DNS server


Who? (dependencies)
===================

(none)


How? (usage)
============

Put configuration files in `/etc/dnsmasq.d/*.conf` (mount it as a volume!) or via `$DNSMASQ_EXTRA_OPTS` environment

	docker-compose [up -d|stop|start] dnsmasq


Where? (volumes)
================

    volumes:
    - /opt/dnsmasq:/opt/dnsmasq:ro
    - /opt/dnsmasq/dnsmasq.d:/etc/dnsmasq.d:ro
    #- /srv/logs/dnsmasq:/var/log

Tip: use https://github.com/javabean/dnsmasq-antispy :-)


Where? (ports)
==============

    expose:
    - "53/tcp"
    - "53/udp"
    ports:
    # also publish service on gateway IP since docker-compose 1.6 can't assign a fixed IP to this container
    - "172.31.1.254:53:53/udp"

    networks:
      vpn:
        ipv4_address: 172.31.53.53


Environment variables
=====================

build-time
----------

(none)

runtime
-------

    environment:
    # --log-queries --log-facility=-
    - DNSMASQ_EXTRA_OPTS=--log-facility=/dev/null --no-hosts -H /opt/dnsmasq/hosts -r /opt/dnsmasq/resolv.conf --cache-size=300 --rebind-domain-ok=/plex.direct/gestionbbox.lan/


Upgrading version
=================
