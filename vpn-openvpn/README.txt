What? (purpose)
===============

VPN (OpenVPN) server

Known issue: no separation between CA management and vpn server

Reference documentation:
* https://community.openvpn.net/openvpn/wiki/HOWTO
* https://community.openvpn.net/openvpn/wiki/FAQ
* https://community.openvpn.net/openvpn/wiki/Openvpn24ManPage

Credits:
* https://github.com/Nyr/openvpn-install
* https://github.com/Angristan/OpenVPN-install


Who? (dependencies)
===================

    depends_on:
    - dnsmasq
    - web-accelerator


How? (usage)
============

	docker-compose [up -d|stop|start] openvpn

Requires host's

	sysctl -w net.ipv4.ip_forward=1
	sysctl -w net.ipv4.conf.all.send_redirects=0

Generated certificates parameters are parametrized via [env vars](https://github.com/OpenVPN/easy-rsa/blob/master/doc/EasyRSA-Advanced.md).

User management scripts (`newClient.sh` & `revokeCLient.sh`) are copied in `/etc/openvpn` (mounted as volume).


Where? (volumes)
================

    volumes:
    - /opt/openvpn:/etc/openvpn
    # Required for `modprobe tun`
    - /lib/modules:/lib/modules:ro
    #- /srv/logs/openvpn:/var/log


Where? (ports)
==============

    ports:
    - "1194/udp:1194/udp"
    #- "1194/tcp:1194/tcp"


Environment variables
=====================

build-time
----------

(none)

runtime
-------

    environment:
    #- PROTOCOL=udp
    #- DNS_USE_RESOLVCONF=true
    #- DNS_EXTRA_SERVER_1=172.31.53.254
    - DNS_EXTRA_SERVER_1=172.31.53.53
    #- DNS_EXTRA_SERVER_2=8.8.4.4
    # OpenVPN extra options
    #- OPENVPN_OPTS=
    # See https://github.com/OpenVPN/easy-rsa/blob/master/doc/EasyRSA-Advanced.md
    - EASYRSA_REQ_COUNTRY=US
    - EASYRSA_REQ_PROVINCE=California
    - EASYRSA_REQ_CITY=San Francisco
    - EASYRSA_REQ_ORG=Copyleft Certificate Co
    #- EASYRSA_REQ_EMAIL=me@example.net
    #- EASYRSA_REQ_OU=My Organizational Unit
    #- EASYRSA_KEY_SIZE=2048
    # CA expiration time in days
    #- EASYRSA_CA_EXPIRE=3650
    # issued cert expiration time in days
    #- EASYRSA_CERT_EXPIRE=3650
    #- EASYRSA_REQ_CN=ChangeMe
    #- EASYRSA_BATCH=


Upgrading version
=================
