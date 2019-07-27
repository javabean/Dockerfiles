What? (purpose)
===============

WordPress server (includes https://wp-cli.org)

Same usage as https://hub.docker.com/_/wordpress/ -- see restore_conf_local.sh for all available options

Note: it will be useful to install a WP plugin like "WP-Mail-SMTP" to use our SMTP relay! :-)


Who? (dependencies)
===================

    links:
    - mysql:mysql
    #- memcached-wordpress:memcached
    - email-relay:email-relay


How? (usage)
============

	docker-compose [up -d|stop|start] wordpress

Exposes APC cache statistics on URL "/wp-admin/apc.php"


Where? (volumes)
================

To save your blog data, mount volumes in
	/var/www/html/.htaccess  (file)
	/var/www/html/wp-config.php  (file)
	/var/www/html/wp-content
	/var/www/html/wp-includes/languages

    volumes:
    - /srv/wordpress/acme-challenge/.well-known:/var/www/html/.well-known
    - /srv/wordpress/htaccess:/var/www/html/.htaccess
    - /srv/wordpress/wp-config.php:/var/www/html/wp-config.php
    - /srv/wordpress/wp-content:/var/www/html/wp-content
    - /srv/wordpress/wp-includes-languages:/var/www/html/wp-includes/languages
    - /srv/logs/wordpress:/var/log


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
      - #WORDPRESS_VERSION=wordpress-4.7.5
      - WORDPRESS_VERSION=latest

runtime
-------

    environment:
    - WORDPRESS_DB_HOST=mysql
    - WORDPRESS_DB_USER=root
    - WORDPRESS_DB_PASSWORD=
    - WORDPRESS_DB_NAME=wordpress
    #- WORDPRESS_TABLE_PREFIX=
    # WordPress key generator: https://api.wordpress.org/secret-key/1.1/salt/
    #- WORDPRESS_AUTH_KEY=
    #- WORDPRESS_SECURE_AUTH_KEY=
    #- WORDPRESS_LOGGED_IN_KEY=
    #- WORDPRESS_NONCE_KEY=
    #- WORDPRESS_AUTH_SALT=
    #- WORDPRESS_SECURE_AUTH_SALT=
    #- WORDPRESS_LOGGED_IN_SALT=
    #- WORDPRESS_NONCE_SALT=


Securing
========

Be sure to follow https://wordpress.org/support/article/hardening-wordpress/ after first installation:
* https://wordpress.org/support/article/hardening-wordpress/  
  (at least "Securing wp-includes", "Securing wp-config.php" & "Disable File Editing")
* https://wordpress.org/support/article/brute-force-attacks/
* https://wordpress.org/support/article/administration-over-ssl/


Monitoring
==========

You can use URL http://www.example.com/wp-includes/wlwmanifest.xml or https://www.example.com/wp-cron.php (in which case be sure to `define( 'DISABLE_WP_CRON', true );`)


Upgrading version
=================

WordPress: online upgrade before upgrading Docker image
