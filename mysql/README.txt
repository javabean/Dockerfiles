What? (purpose)
===============

MySQL server

Same usage as https://hub.docker.com/r/mysql/mysql-server/


Who? (dependencies)
===================

(none)


How? (usage)
============

	docker-compose [up -d|stop|start] mysql

Forces character set to UTF-8  
Use MYSQL_CUSTOM_OPTS env to pass extra mysqld parameters

To shut down:
$ docker exec mysql_docker_name  mysqladmin shutdown
or
$ docker exec mysql_docker_name  killall -TERM -u mysql


Where? (volumes)
================

Data directory: /var/lib/mysql  
Will automatically backup the database every day in /srv if the file /srv/dump.sql.gz exists

    volumes:
    - /opt/mysql/docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d
    - /srv/mysql/data:/var/lib/mysql
    - /srv/mysql/backup:/srv
    - /srv/logs/mysql:/var/log


Where? (ports)
==============

    expose:
    - "3306"


Environment variables
=====================

build-time
----------

    build:
      args:
      - MYSQL_VERSION=5.6

runtime
-------

    environment:
    - MYSQL_ROOT_PASSWORD=
    #- MYSQL_CUSTOM_OPTS=--table_open_cache=500 --max_connections=51
    #- MYSQL_CUSTOM_OPTS=--key_buffer_size=4M --sort_buffer_size=128K --read_buffer_size=64K --net_buffer_length=8K
    #- MYSQL_CUSTOM_OPTS=--innodb_buffer_pool_size=64M --innodb_log_buffer_size=8M
    #- MYSQL_CUSTOM_OPTS=--default-storage-engine=MyISAM --default_tmp_storage_engine=MyISAM
    #- MYSQL_CUSTOM_OPTS=--sql-mode=NO_ENGINE_SUBSTITUTION
    # http://bugs.mysql.com/bug.php?id=68287
    # There are thresholds based on table_open_cache and table_definition_cache and max_connections and crossing the thresholds produces a big increase in RAM used. The thresholds work by first deciding if the server size is small, medium or large.
    # Small: all three are same as or less than defaults (2000, 400, 151). (max 52.6 megabytes RAM)
    # Large: any of the three is more than twice the default. (min 400 megabytes RAM)
    # Medium: others. (90.7-98.4 megabytes RAM)
    # instead of turning off performance_schema, you can reduce RAM usage with --table_open_cache=400 --table_definition_cache=400 --max_connections=151
    - MYSQL_CUSTOM_OPTS=--performance_schema=off


Upgrading version
=================

See http://dev.mysql.com/doc/refman/5.7/en/mysql-upgrade.html
