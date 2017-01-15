What? (purpose)
===============

Base Apache httpd image


Who? (dependencies)
===================

(none)


How? (usage)
============

Dockerfile: `FROM cedrik/httpd-base:latest`

Can run `/usr/local/bin/backup_conf_local.sh` while building Docker image, if you call (in sub-image Dockerfile) `RUN /usr/local/bin/backup_conf.sh`

Will run `/usr/local/bin/restore_conf_local.sh` before starting Apache


Where? (volumes)
================

(none)


Where? (ports)
==============

(none)


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

