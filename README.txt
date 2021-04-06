GENERAL PRINCIPLES
==================

Docker stack for all my online services. Or my travel from pet to cattle.  
"Docker stack" here means infrastructure, (almost) not applications configuration!  
No Swarm / Kubernetes / Fleet / Mesos / Consul / etcd / registrator / confd / ...; this stack is small enough for a single host.  
Base image loosely based on phusion's baseimage-docker.

Configuration is in host's `/opt`  
Data is in host's `/srv`  
Logs are in host's `/srv/logs`  
Everything is stored on host (i.e. no data volumes), mounted via `docker-compose.yml`  
All sensitive configuration data (passwords, environment variables, &c.) in non-committed `docker-compose.override.yml`

Makefile to install, build, cleanup & stats, but not for running (tip: use `docker-compose up -d <name>`).

All HTTP(s) services are behind a front HTTP proxy (aptly named `http-proxy`).

As much as I would like to separate all services, there is only a single MySQL container. I don't have enough RAM for multiple MySQL instances… :-/

Images hierarchy:
Tomcat
MySQL
AdGuard Home
Nextcloud
WordPress	(requires mysql, email-relay[, memcached])
WebSSH
TiddlyWiki*
php7-apache
	Tiny Tiny RSS
	DokuWiki	(requires email-relay)
	owncloud	(requires email-relay, redis, memcached[, mysql])
baseimage
	Dovecot
	apache-base
		http-proxy
	email-relay
	OpenVPN	(requires AdGuard Home, ziproxy)
	ziproxy
	Transmission
	sslh
* = not ready yet

For dependencies and additional usage notes, go read `docker-compose.yml` :-)


MAINTENANCE
===========
(version management & upgrades)

`Makefile`: adjust `${*}` vars

`docker-compose.override.yml`: adjust `${*}` vars

`baseimage/image/Dockerfile`: `FROM`: check and adjust guest OS version (e.g. 18.04)  
`baseimage/image/buildconfig`

`.env` : check and adjust `MYSQL_VERSION`

`vpn-openvpn/Dockerfile`: check and adjust EasyRSA version

ownCloud: manually `/usr/local/bin/ownCloudUpgrade.sh` after Docker image upgrade

WordPress: online upgrade before upgrading Docker image

DokuWiki: online upgrade before upgrading Docker image
	http://www.dokuwiki.org/plugin:upgrade
	`/usr/local/bin/upgrade-dokuwiki.sh`

TiddlyWiki: update your installed plugins, themes & languages after upgrading Docker image

mysql/Dockerfile:
		version upgrades:
			https://dev.mysql.com/doc/refman/8.0/en/upgrading.html
			https://dev.mysql.com/doc/refman/8.0/en/mysql-upgrade.html
			mysql -u root -p --execute="SET GLOBAL innodb_fast_shutdown=0"
			mysqladmin -u root -p shutdown
			??? mysqlcheck -u root -p --all-databases --check-upgrade
