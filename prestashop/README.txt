What? (purpose)
===============

PrestaShop server

About same usage as https://hub.docker.com/r/prestashop/prestashop/ -- see restore_conf_local.sh for all available options  
In particular, can rename "/admin" via $PS_FOLDER_ADMIN environment variable


Who? (dependencies)
===================

    links:
    - mysql:mysql
#    - memcached-prestashop:memcached
    - email-relay:email-relay


How? (usage)
============

docker-compose [up -d|stop|start] prestashop

Exposes APC cache statistics on URL "/$PS_FOLDER_ADMIN/apc.php"


Where? (volumes)
================

To save your shop data, mount volumes in
	/var/www/html/.htaccess  (file)
	/var/www/html/override
	/var/www/html/mails
	/var/www/html/img
	/var/www/html/modules
	/var/www/html/download
	/var/www/html/upload
	/var/www/html/config

    volumes:
    - /srv/prestashop/acme-challenge/.well-known:/var/www/html/.well-known
    - /srv/prestashop/htaccess:/var/www/html/.htaccess
    - /srv/prestashop/override:/var/www/html/override
    #- /srv/prestashop/mails:/var/www/html/mails
    # tous les dossiers du dossier /img, sauf /img/admin et /img/jquery-ui
    - /srv/prestashop/img:/var/www/html/img
    # Ne copiez que les modules que vous avez ajoutés depuis que vous avez installé PrestaShop la première fois (et qui ne font donc pas partie de l'installation par défaut).
    - /srv/prestashop/modules:/var/www/html/modules
    #- /srv/prestashop/themes/votreTheme:/var/www/html/themes/votreTheme
    # produits téléchargeables, les fichiers attachés, et les produits personnalisables
    - /srv/prestashop/download:/var/www/html/download
    - /srv/prestashop/upload:/var/www/html/upload
    - /srv/prestashop/config:/var/www/html/config
#    - /srv/prestashop/config/config.inc.php:/var/www/html/config/config.inc.php
#    - /srv/prestashop/config/defines.inc.php:/var/www/html/config/defines.inc.php
#    - /srv/prestashop/config/settings.inc.php:/var/www/html/config/settings.inc.php
#    - /srv/prestashop/config/smarty.config.inc.php:/var/www/html/config/smarty.config.inc.php
    #- /srv/prestashop/translations/myTranslation:/var/www/html/translations/myTranslation
    - /srv/prestashop/translations/fr:/var/www/html/translations/fr
#    - /srv/prestashop/admin-backups:/var/www/html/${PS_FOLDER_ADMIN}/backups/
    - /srv/logs/prestashop:/var/log


Where? (ports)
==============

    expose:
    - "80"
    - "443"


Environment variables
=====================

build-time
----------

    build:
      args:
      - PRESTASHOP_VERSION=1.6.0.14

runtime
-------

    environment:
    - PS_FOLDER_ADMIN=admin
    - PS_FOLDER_INSTALL=install
    - PS_INSTALL_AUTO=0
    - DB_SERVER=mysql
    - DB_USER=
    - DB_PASSWD=
    #- DB_NAME=
    - PS_LANGUAGE=fr
    - PS_COUNTRY=fr
    - PS_TIMEZONE=Europe/Paris
    - PS_DOMAIN=www.example.com
    - ADMIN_FIRST_NAME=Admin
    - ADMIN_LAST_NAME=Istrator
    - ADMIN_MAIL=prestashop-admin@example.com
    - ADMIN_PASSWD=changeme
    - ADMIN_NEWSLETTER=0
    - ADMIN_SEND_EMAIL=1


Upgrading version
=================

Prestashop: online upgrade before upgrading Docker image, then re-install translation via back-office
	html/mails/fr/
	html/themes/default-bootstrap/lang/fr.php
	html/translations/fr/
