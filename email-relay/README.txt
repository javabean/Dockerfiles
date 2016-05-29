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

See http://www.opendkim.org/opendkim-README for key generation & configuration; in short:
	* opendkim-genkey -r -s SELECTOR [-t] -D /opt/email-relay/dkim/keys/example.net/ --domain=example.net
	* add example.net configuration in /opt/email-relay/dkim/SigningTable and /opt/email-relay/dkim/KeyTable
	* publish /opt/email-relay/dkim/keys/example.net/SELECTOR.txt in SELECTOR._domainkey.example.net DNS TXT record


Where? (volumes)
================

Put configuration (mount volumes) in:
	/opt/email-relay/dkim/TrustedHosts
	/opt/email-relay/dkim/KeyTable
	/opt/email-relay/dkim/SigningTable
	/opt/email-relay/dkim/keys/

    volumes:
    - /opt/email-relay:/opt/email-relay:ro
#    - /srv/logs/email-relay:/var/log


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

