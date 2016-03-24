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
			wordpress*
			wallabag*
	mysql
	email-relay
	dnsmasq
	memcached
	redis
	openvpn
	letsencrypt
* = not done yet

For dependencies and additional usage notes, go read docker-compose.yml :-)


MAINTENANCE
===========
(version management)

Makefile: adjust ${*} vars

docker-compose.override.yml: adjust ${*} vars

baseimage/image/Dockerfile: FROM: check and adjust guest OS version (e.g. 15.10)

vpn-openvpn/Dockerfile: check and adjust EasyRSA version

ownCloud: manually upgrade installed additional applications (i.e. those not coming from ownCloud package)

Prestashop: online upgrade before upgrading Docker image, then re-install translation via back-office
	html/mails/fr/
	html/themes/default-bootstrap/lang/fr.php
	html/translations/fr/

mysql/Dockerfile:
		version upgrades: http://dev.mysql.com/doc/refman/5.7/en/mysql-upgrade.html
		(Beware Prestashop 1.6 is not yet compatible with MySQL 5.7)


ToDo
====

More documentation for each Docker
	at least: purpose/usage, volumes, ports, environment variables

Docker 1.10 + Compose 1.6:
	switch to Networking (config nearly ready; now where is that f*** documentation?!?)

Joomla: check upgrade

email-relay
	DediBox IP block was black-listed:
		http://multirbl.valli.org/lookup/195.154.79.138.html
		-> Le mieux pour vous est de vous inscrire aux listes JMRP, SFP et d'installer une clé DKIM sur votre serveur.
			DKIM > https://support.google.com/a/answer/174124?hl=fr&ref_topic=2752442
			JMRP > https://documentation.online.net/fr/serveur-dedie/reseau/inscription-jmrp
			fin : DMARC > https://support.google.com/a/answer/2466580

vpn: IKEv2
	probably only OpenVPN since Docker only relay IP protocol (i.e. no GRE)
	https://raymii.org/s/tutorials/IPSEC_vpn_with_Ubuntu_15.10.html

Dovecot: configure Sieve (dovecot-managesieved)
	not much use without an LDA / LMTP...
	how to secure ManageSieve?

Switch to "read_only: true" once docker-compose supports tmpfs...
	https://github.com/docker/compose/issues/2778
	https://github.com/docker/compose/pull/2978

If going with systemd in containers, need to change stop (TERM) signal to SIGPWR
