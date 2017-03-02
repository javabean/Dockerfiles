What? (purpose)
===============

Simple open SMTP relay (Postfix), with DKIM support.  
Used for internal email sending only.

WARNING: never, /never/, *never* put this image directly accessible from Internet!


Who? (dependencies)
===================

(none)


How? (usage)
============

	docker-compose [up -d|stop|start] email-relay

Use `/usr/local/bin/dkim_new_domain.sh` for key generation & configuration


Where? (volumes)
================

Put configuration (mount volumes) in:
	/usr/local/etc/dkim/TrustedHosts
	/usr/local/etc/dkim/KeyTable
	/usr/local/etc/dkim/SigningTable
	/usr/local/etc/dkim/keys/

    volumes:
    - /opt/email-relay/dkim:/usr/local/etc/dkim:ro
    #- /srv/logs/email-relay:/var/log


Where? (ports)
==============

    expose:
    - "25"


Environment variables
=====================

build-time
----------

Set Postfix hostname via POSTFIX_HOSTNAME env at build time.

    build:
      args:
      - POSTFIX_HOSTNAME=myhost.example.net

runtime
-------

(none)


Upgrading version
=================

