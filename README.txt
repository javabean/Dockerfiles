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
baseimage
	consul
	dovecot
	java
		tomcat
	apache-base
		http-proxy
		php7-base
			owncloud	(requires email-relay, redis, memcached[, mysql])
			wordpress	(requires mysql, email-relay[, memcached])
			dokuwiki	(requires email-relay)
	tiddlywiki*
	mysql
	email-relay
	dnsmasq
	unbound	(requires dnsmasq)
	openvpn	(requires dnsmasq, ziproxy)
	ziproxy
	transmission
	sslh
* = not ready yet

For dependencies and additional usage notes, go read `docker-compose.yml` :-)


MAINTENANCE
===========
(version management & upgrades)

`Makefile`: adjust `${*}` vars

`docker-compose.override.yml`: adjust `${*}` vars

`baseimage/image/Dockerfile`: `FROM`: check and adjust guest OS version (e.g. 16.04)  
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
			https://dev.mysql.com/doc/refman/5.7/en/upgrading.html
			https://dev.mysql.com/doc/refman/5.7/en/mysql-upgrade.html
			mysql -u root -p --execute="SET GLOBAL innodb_fast_shutdown=0"
			mysqladmin -u root -p shutdown
			mysql_upgrade -u root -p
