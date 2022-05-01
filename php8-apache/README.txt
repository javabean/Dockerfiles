What? (purpose)
===============

Base Apache + PHP 8.0 image (via mod-php8, not php-fmp)


Who? (dependencies)
===================

(none)


How? (usage)
============

Dockerfile: `FROM cedrik/php8-apache:latest`

To run `read_only: true`, you will need:
    tmpfs:
    # default tmpfs opts: rw,nosuid,nodev,noexec,relatime,size=65536k
    - /run:rw,nosuid,noexec,relatime,size=65536k,mode=755
    - /run/lock:rw,nosuid,nodev,noexec,relatime,size=5120k,mode=1777
    - /tmp:rw,nosuid,nodev,noexec,size=131072k,mode=1777,strictatime
    # PHP.ini 'session.save_path'; 33=www-data
    - /var/lib/php/sessions:rw,nosuid,nodev,noexec,relatime,size=65536k,mode=1755,uid=www-data,gid=www-data


Where? (volumes)
================

(none)


Where? (ports)
==============

80


Environment variables
=====================

build-time
----------

(none)

runtime
-------

`ENABLE_CRON`: launch crond as a daemon (put your user crontabs in `/var/spool/cron/crontabs/`)


Upgrading version
=================

