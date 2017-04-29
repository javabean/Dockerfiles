What? (purpose)
===============

[Consul](https://www.consul.io/) server


Who? (dependencies)
===================

(none)


How? (usage)
============

	docker-compose [up -d|stop|start] consul


Where? (volumes)
================

    volumes:
    - /opt/consul/config:/usr/local/etc/consul:ro
    - /srv/consul/data:/srv/consul/data


Where? (ports)
==============

8300: Server RPC, used for communication between Consul clients and servers for internal request forwarding
8301, 8302: Serf LAN and WAN (WAN is used only by Consul servers), used for gossip between Consul agents. LAN is within the datacenter and WAN is between just the Consul servers in all datacenters.
8400: CLI
8500: HTTP
8600 or 53: DNS

    expose:
    - "8300"
    - "8301"
    - "8301/udp"
    - "8302"
    - "8302/udp"
    - "8400"
    - "8500"
    - "8600"
    - "8600/udp"
    - "53"
    - "53/udp"


Environment variables
=====================

build-time
----------

(none)

runtime
-------

    environment:
    # See https://www.consul.io/docs/agent/options.html
    - CONSUL_OPTS=-bootstrap-expect 1 -datacenter dc1


Upgrading version
=================

See https://www.consul.io/docs/upgrading.html and https://www.consul.io/docs/upgrade-specific.html
