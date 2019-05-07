What? (purpose)
===============

Tomcat 8 server

Running user is tomcat:tomcat (uid: 8080 guid: 8080)


Who? (dependencies)
===================

    links:
    - email-relay:email-relay


How? (usage)
============

Offers CATALINA_HOME in /usr/local/tomcat  
Set CATALINA_BASE (e.g. /opt/tomcat/my-instance) before running!

	docker-compose [up -d|stop|start] tomcat


Where? (volumes)
================

    volumes:
    - /opt/tomcat:/opt/tomcat


Where? (ports)
==============

    expose:
    - "8080"
    - "8443"


Environment variables
=====================

build-time
----------

    build:
      args:
      - DOCKER_FROM_VERSION=8.5-jre8-slim

runtime
-------

    environment:
    - CATALINA_BASE=/opt/tomcat/my-instance


Upgrading version
=================
