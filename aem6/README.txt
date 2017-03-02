What? (purpose)
===============

Adobe AEM 6 server (ex CQ / Communiqué) (Java part, no dispatcher)

Running user is `aem6:aem6` (uid: 4502 guid: 4502)


Who? (dependencies)
===================

    #links:
    #- email-relay:email-relay
    #- mongodb:mongodb
    #...


How? (usage)
============

	docker-compose [up -d|stop|start] aem

Starts a CQ / AEM instance with the following properties:

* env vars passed-in via Docker, or declared in file /usr/local/etc/aem6
* cq / aem jar is copied at build-time in `/opt/aem6/aem-*.jar` or `/opt/aem6/cq-*.jar` (see `AEM_JAR_URL`)
* cq / aem install directory is `${CQ_BASEFOLDER:-/srv/aem6}`
* cq / aem licence file is `${CQ_BASEFOLDER:-/srv/aem6}/license.properties`
* cq / aem packages (SP / CFP / hotfixes / featurepacks / ...) to install at startup in `${PACKAGES_ROOT:-/opt/aem6/packages}`

Packages will be installed 1 by 1 at startup (via HTTP API) in lexical order, and will be deleted when installed.  
To restart the AEM instance, simply input an empty file.

Bonus: can also remove Geometrixx if `${REMOVE_GEOMETRIXX}` is set


Where? (volumes)
================

    volumes:
    #- /opt/aem/config:/usr/local/etc/aem6
    - /opt/aem6/packages:/opt/aem6/packages
    - /srv/aem6:/srv/aem6


Where? (ports)
==============

    expose:
    - "4502"
    - "4503"


Environment variables
=====================

build-time
----------

    build:
      args:
      - AEM_JAR_URL=http://server.example:8081/nexus/content/repositories/thirdparty/com/adobe/aem/aem/6.2.0.1/aem-6.2.0.1-generic.jar
      #- IMAGEMAGICK=1
      #- FFMPEG=1

Uncomment `IMAGEMAGICK` to install ImageMagick.  
Uncomment `FFMPEG`to install FFmpeg.

runtime
-------

    environment:
    # See /usr/local/etc/aem6 for all possible keys
    - CQ_AUTH=admin:admin
    - CQ_PORT=4502
    - CQ_RUNMODE=author,nosamplecontent
    #- CQ_JVM_OPTS=...
    #- REMOVE_GEOMETRIXX=true
    ...


Upgrading version
=================

You don't want to upgrade AEM without some deep thinking. Really. :-)
