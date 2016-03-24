Same usage as https://hub.docker.com/r/mysql/mysql-server/

Forces character set to UTF-8
Use MYSQL_CUSTOM_OPTS env to pass extra mysqld parameters

Data directory: /var/lib/mysql
Will automatically backup the database every day in /srv if the file /srv/dump.sql.gz exists

To shut down:
$ docker exec mysql_docker_name  mysqladmin shutdown
or
$ docker exec mysql_docker_name  killall -TERM -u mysql
