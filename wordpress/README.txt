What? (purpose)
===============

WordPress server (includes https://wp-cli.org)

This is https://hub.docker.com/_/wordpress/ with some configuration (httpd, PHP, WordPress) tacked on.

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
    - /srv/wordpress/htaccess:/var/www/html/.htaccess
    - /srv/wordpress/wp-config.php:/var/www/html/wp-config.php
    - /srv/wordpress/wp-content:/var/www/html/wp-content
    - /srv/wordpress/wp-includes-languages:/var/www/html/wp-includes/languages


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
      - DOCKER_FROM_TAG=5.6.2-php7.4-apache

runtime
-------

    # See https://hub.docker.com/_/wordpress/
    environment:
    - WORDPRESS_DB_HOST=mysql
    - WORDPRESS_DB_USER=root
    - WORDPRESS_DB_PASSWORD=
    - WORDPRESS_DB_NAME=wordpress
    - WORDPRESS_DB_CHARSET=utf8mb4
    - WORDPRESS_DB_COLLATE=utf8_general_ci
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
    #- WORDPRESS_CONFIG_EXTRA=


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
Updgrading the Docker image will also bring you more recent PHP and Apache httpd.
