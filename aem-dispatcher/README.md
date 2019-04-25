AEM dispatcher
==============

Scripts to install AEM dispatcher instance in Docker, or bare metal on RedHat | CentOS 7 (systemd).

Publish dispatcher instance can multi-host (see `dispatcher-add-domain.sh`) and optionally make use of [ACS AEM Commons Redirect Map Manager](https://adobe-consulting-services.github.io/acs-aem-commons/features/redirect-map-manager/index.html) to keep an Apache httpd RewriteMap up to date (using an external `cron` container).



Installing in Docker
====================

Adjust variables in `docker-compose.yml`, and then:

		docker-compose build
		docker-compose up -d [dispatcher-publish|dispatcher-author]



Installing in CentOS 7
======================

Dispatcher for AEM publish
--------------------------

	sudo sh install-dispatcher.sh -p 127.0.0.1

`-p` : associated AEM publish instance IP (or `127.0.0.1` if on same VM)


Dispatcher for AEM author
-------------------------

	sudo sh install-dispatcher.sh -a 127.0.0.1

`-a` : associated AEM author instance IP (or `127.0.0.1` if on same VM)


Adding a (publish) web domain (tenant)
======================================

Adding one or more domain names in a multi-tenant AEM hosting requires applying the change at several layers:
* AEM publish, so that it can associate a domain name to the correct `/content/my-site` repository branch (Sling Mapping: `/etc/map`)
* AEM dispatcher, so that it can manage sites caches in separate partitions
* Apache httpd (`VirtualHost`), to apply site-specific URL rewrite rules
* network elements like TLS terminator, load balancer, WAF, &c.
* CDNs (if any)

For each group a domains (tenants):

### AEM author (optional)

If your CMS contributors want to manage URL redirection rules, create in AEM author the site-specific [ACS AEM Commons Redirect Map](https://adobe-consulting-services.github.io/acs-aem-commons/features/redirect-map-manager/index.html) page (`http://${AUTHOR_HOST}:4502/miscadmin#/etc/acs-commons/redirect-maps`). The dispatcher will regularly come and fetch the rewrite rules.

Tip: is using our AEM Docker container, you can use:

		/usr/local/bin/aem-functions.sh /usr/local/etc/aem6 acs_aem_commons_redirect_map_create ${AUTHOR_HOST}:4502 admin:${ADMIN_PASSWD} ${MAP_FILE}

where `${MAP_FILE}` is the tenant main site domaine name (i.e. Redirect Map page name)

### (publish) dispatcher

On each (publish) dispatcher instance:

		sudo sh dispatcher-add-domain.sh -n aem_node_name -d example.com -d www.example.com -c admin:${ADMIN_PASSWD} -r http://${PUBLISH_HOST}:4503/etc/acs-commons/redirect-maps/${MAP_FILE}/jcr:content.redirectmap.txt"

`aem_node_name` is the AEM node name under `/content` which is the web site root. For example, for We.Retail, this would be `we-retail` since the site node lives at `/content/we-retail`.

`-c` and `-r` are only to be used if you configured and ACS AEM Commons RedirectMap on author (and published the associated page).

Should you need to modify / add another domain to the tenant, the configuration files to edit will be `${HTTPD_CONF_D}/farm_${PRIMARY_DOMAIN}.conf` (`ServerName` & `ServerAlias`) and `${HTTPD_CONF_D}/inc-virtualhosts_${PRIMARY_DOMAIN}.any`.

### AEM publish

You will need to code the AEM / Sling `/etc/map` configuration and deploy it on our publish instances (adapt according to your domain names):
```
/etc/map/https/<site_id>
	sling:match	www\.example\.com\.\\d+
	sling:internalRedirect	[ /content/<site_id> , / ]
/etc/map/https/<site_id>/libs
	sling:internalRedirect	/libs
/etc/map/https/<site_id>/etc
	sling:internalRedirect	/etc
/etc/map/https/<site_id>/etc/design
	sling:internalRedirect	/etc/design
/etc/map/https/<site_id>/etc/clientlibs
	sling:internalRedirect	/etc/clientlibs
/etc/map/https/<site_id>/etc.clientlibs
	sling:internalRedirect	/etc.clientlibs
/etc/map/https/<site_id>/conf
	sling:internalRedirect	/conf
/etc/map/https/<site_id>/content-dam
	sling:match	(?:content/)?dam
	sling:internalRedirect	/content/dam
```
Should you need to remove the `.html` extension on URLs:
```
/etc/map/https/<site_id>/reverse_mapping
	sling:match	$1
	sling:internalRedirect	/content/<site_id>/(.+)\.html
```
Copy the same hierarchy to `/etc/map/http`.

([AEM documentation](https://helpx.adobe.com/experience-manager/6-4/sites/deploying/using/resource-mapping.html)
| [Sling documentation](https://sling.apache.org/documentation/the-sling-engine/mappings-for-resource-resolution.html)
)



Installation details (what is installed where and how, &c.)
===========================================================

See `httpd-environment.sh` for variables values, depending on whether we are running in a Docker container, or in a CentOS 7 VM.

Docker:

		HTTPD_PREFIX=/usr/local/apache2
		HTTPD_HTDOCS=/usr/local/apache2/htdocs
		HTTPD_LOGS=/usr/local/apache2/logs
		HTTPD_CONF=/usr/local/apache2/conf
		HTTPD_CONF_D=/usr/local/apache2/conf.d
		HTTPD_CONF_MODULES_D=/usr/local/apache2/conf.modules.d
		HTTPD_MODULES=/usr/local/apache2/modules
		HTTPD_USER=www-data

CentOS 7:

		HTTPD_PREFIX=/etc/httpd
		HTTPD_HTDOCS=/var/www/html
		HTTPD_LOGS=/etc/httpd/logs
		HTTPD_CONF=/etc/httpd/conf
		HTTPD_CONF_D=/etc/httpd/conf.d
		HTTPD_CONF_MODULES_D=/etc/httpd/conf.modules.d
		HTTPD_MODULES=/etc/httpd/modules
		HTTPD_USER=apache


httpd + dispatcher
------------------

### Installed files locations

		${HTTPD_LOGS}					httpd logs
		${HTTPD_HTDOCS}					Apache httpd dispatcher cache
		/usr/local/bin/					Miscellaneous scripts (also used by cron)
		${HTTPD_CONF} & ${HTTPD_CONF_D} & ${HTTPD_CONF_MODULES_D}
								Apache httpd & dispatcher configuration files
		${HTTPD_MODULES}				Adobe Dispatcher httpd module binary

System user: `${HTTPD_USER}`

Crontab (CentOS): `root`

### Installation steps

1. Install system Apache httpd service (CentOS only; provided by base image for Docker)
2. Install AEM dispatcher in `${HTTPD_MODULES}/*dispatcher*`
3. Configure httpd & AEM dispatcher (`${HTTPD_CONF_MODULES_D}/*dispatcher*` & `${HTTPD_CONF_D}/*`)

(For details, see `install-dispatcher.sh`)

Log rotation is done via `rotatelogs` (in httpd configuration files).

#### Dispatcher configuration files details

The main dispatcher httpd module is in file `${HTTPD_CONF_D}/dispatcher.conf`.

Each (publish) tenant (`VirtualHost`) can have one or more domain names. The first one is your "primary domain".

Each (publish) tenant configuration is in files:
* `${HTTPD_CONF_D}/farm_${PRIMARY_DOMAIN}.conf`
* `${HTTPD_CONF_D}/*${PRIMARY_DOMAIN}.any`

The associated httpd `RewriteMap` configuration is in files `${HTTPD_CONF}/farm_${PRIMARY_DOMAIN}.*` and is updated by a root cron (CentOS) | external cron container (Docker) `httpd-rewritemap-update.sh` which will regularly fetch it on the AEM publish instance (`-c` & `-r` parameters of `dispatcher-add-domain.sh`).
