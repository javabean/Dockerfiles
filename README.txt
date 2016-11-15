GENERAL PRINCIPLES
==================

Docker stack for all my online services.
"Docker stack" here means infrastructure, (almost) not applications configuration!
No Swarm / Kubernetes / Fleet / Mesos / Consul / etcd / registrator / confd / ...; this stack is small enough for a single host.
Base image loosely based on phusion's baseimage-docker.

Configuration is in host's /opt
Data is in host's /srv
Logs are in host's /srv/logs
Everything is stored on host (i.e. no data volumes), mounted via docker-compose.yml
All sensitive configuration data (passwords, environment variables, &c.) in non-committed docker-compose.override.yml

Makefile to install, build, cleanup & stats, but not for running (tip: use docker-compose up -d <name>).

All HTTP(s) services are behind a front HTTP proxy (aptly named http-proxy).

As much as I would like to separate all services, there is only a single MySQL container. I don't have enough RAM for multiple MySQL instances… :-/

Images hierarchy:
baseimage
	dovecot
	java
		tomcat
	apache-base
		http-proxy
		php5-base
			owncloud	(requires email-relay, redis, memcached[, mysql])
			prestashop	(requires mysql, email-relay[, memcached])
			joomla 		(requires mysql, email-relay[, memcached])
			wordpress	(requires mysql, email-relay[, memcached])
			dokuwiki	(requires email-relay)
	tiddlywiki
	mysql
	email-relay
	dnsmasq
	unbound	(requires dnsmasq)
	memcached
	redis
	openvpn	(requires dnsmasq, ziproxy)
	ziproxy
	transmission
	netdata
	letsencrypt*
* = not done yet

For dependencies and additional usage notes, go read docker-compose.yml :-)


MAINTENANCE
===========
(version management & upgrades)

Makefile: adjust ${*} vars

docker-compose.override.yml: adjust ${*} vars

baseimage/image/Dockerfile: FROM: check and adjust guest OS version (e.g. 16.04)
baseimage/image/buildconfig

.env : check and adjust MYSQL_VERSION

vpn-openvpn/Dockerfile: check and adjust EasyRSA version

ownCloud: manually /ownCloudUpgrade.sh after Docker image upgrade

Prestashop: online upgrade before upgrading Docker image, then re-install translation via back-office
	html/mails/fr/
	html/themes/default-bootstrap/lang/fr.php
	html/translations/fr/

Joomla: online upgrade before upgrading Docker image
	https://docs.joomla.org/Portal:Upgrading_Versions

WordPress: online upgrade before upgrading Docker image

DokuWiki: online upgrade before upgrading Docker image
	http://www.dokuwiki.org/plugin:upgrade

TiddlyWiki: update your installed plugins, themes & languages after upgrading Docker image

mysql/Dockerfile:
		version upgrades: http://dev.mysql.com/doc/refman/5.7/en/mysql-upgrade.html
		(Beware Prestashop < 1.6.1.4 is not compatible with MySQL 5.7 nor PHP7)
