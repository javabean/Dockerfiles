#FROM php:5.6-apache
FROM cedrik/httpd-base:latest
MAINTAINER Cédrik LIME

############### FIXME  change depending on base OS / version! ###############
ARG MYSQL_VERSION=5.6

# http://dev.mysql.com/doc/refman/5.7/en/checking-gpg-signature.html
RUN gpg --keyserver keys.gnupg.net --recv-keys 5072E1F5 \
	&& gpg --export -a 5072E1F5 | apt-key add -

RUN echo "deb http://repo.mysql.com/apt/ubuntu/ `lsb_release --codename | cut -f 2` mysql-${MYSQL_VERSION}" > /etc/apt/sources.list.d/mysql.list

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	curl bzip2 openssl file \
	libapache2-mod-php5 libapache2-mod-bw libapache2-mod-rpaf \
#	libapache2-mod-security2 \
	php5-gd php5-json php5-mysql php5-curl php5-intl php5-mcrypt php5-imagick \
	php5 php5-cli php5-ldap php5-memcache php5-memcached php5-readline php5-sqlite \
	php5-apcu \
	mysql-client \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& a2dismod mpm_event && a2enmod mpm_prefork \
	&& for m in "rewrite headers env dir mime"; do a2enmod $m; done \
# copy conf dirs to enable populating empty volumes (see runit_apache2)
	&& /usr/local/bin/backup_conf.sh

#RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
#	&& docker-php-ext-install gd intl mbstring mcrypt mysql pdo_mysql pdo_pgsql pgsql zip

# PECL extensions
#RUN pecl install APCu-beta redis memcached \
#	&& docker-php-ext-enable apcu redis memcached

# PHP configuration
RUN sed -i'.bak' -e 's%\(upload_max_filesize\) = 2M%\1 = 8M%' \
	-e 's%\(session.cookie_httponly\) =.*%\1 = On%' \
	-e 's%\(session.hash_function\) = 0%\1 = 1%' \
	  /etc/php5/apache2/php.ini

#VOLUME /var/www/html
#VOLUME ["/var/log"]

EXPOSE 80 443

CMD ["/sbin/my_init"]
