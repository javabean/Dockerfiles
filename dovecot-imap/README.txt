What? (purpose)
===============

IMAP Dovecot server with local (non-system) users only


Who? (dependencies)
===================

(none)


How? (usage)
============

	docker-compose [up -d|stop|start] dovecot

First run will take a bit of time while generating DH parameters. Subsequent runs will be much faster.  
You can mount a pre-computed /var/lib/dovecot/ssl-parameters.dat to avoid this.


Where? (volumes)
================

Put configuration in /opt/dovecot/local.conf (or mount /etc/dovecot/local.conf file)  
Put local users in /opt/dovecot/passwd (or mount /etc/dovecot/users file)

    volumes:
    - /opt/dovecot:/opt/dovecot:ro
    - /srv/dovecot:/srv/dovecot
    - /srv/logs/dovecot:/var/log


Where? (ports)
==============

    ports:
    # IMAP(s)
    #- "143:143"
    - "993:993"
    # POP3(s)
    #- "110:110"
    #- "995:995"
    # SMTP / submission / SMTPs
    #- "25:25"
    #- "587:587"
    #- "465:465"
    # Sieve
    #- "4190:4190"


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

