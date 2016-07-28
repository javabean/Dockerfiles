#FROM php:7.0-apache
FROM cedrik/httpd-base:latest
MAINTAINER Cédrik LIME

############### FIXME  change depending on base OS / version! ###############
ARG MYSQL_VERSION=5.6

# http://dev.mysql.com/doc/refman/5.7/en/checking-gpg-signature.html
#RUN gpg --keyserver keys.gnupg.net --recv-keys 5072E1F5 \
#	&& gpg --export -a 5072E1F5 | apt-key add -
RUN apt-key adv --keyserver pgp.mit.edu --recv-keys 5072E1F5

RUN echo "deb http://repo.mysql.com/apt/ubuntu/ `lsb_release --codename | cut -f 2` mysql-${MYSQL_VERSION}" > /etc/apt/sources.list.d/mysql.list

RUN LC_ALL=C.UTF-8  add-apt-repository -y ppa:ondrej/php \
	&& apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	curl bzip2 openssl file \
	libapache2-mod-php7.0 libapache2-mod-bw libapache2-mod-rpaf \
#	libapache2-mod-security2 \
	php7.0-gd php7.0-json php7.0-curl php7.0-intl php7.0-mcrypt  php7.0-imagick \
	php7.0 php7.0-cli php7.0-readline php7.0-sqlite3 \
	php7.0-apcu php7.0-memcache php7.0-memcached \
	php7.0-bz2 php7.0-mbstring php7.0-soap php7.0-xml php7.0-zip \
#	php7.0-fpm php7.0-ldap \
	php7.0-mysql mysql-client=${MYSQL_VERSION}.* mysql-common=${MYSQL_VERSION}.* \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& a2dismod mpm_event && a2enmod mpm_prefork \
	&& a2dismod -f deflate \
	&& for m in "rewrite headers env dir mime"; do a2enmod $m; done \
	&& if ! test -f /usr/share/doc/php-apcu/apc.php; then curl -fsSL http://pecl.php.net/get/APCu | tar xz -C /usr/share/doc/php-apcu/ --strip-components=1 --wildcards apcu*/apc.php; fi \
# copy conf dirs to enable populating empty volumes (see runit_apache2)
	&& /usr/local/bin/backup_conf.sh

#RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
#	&& docker-php-ext-install gd intl mbstring mcrypt mysql pdo_mysql pdo_pgsql pgsql zip

# PECL extensions
#RUN pecl install APCu-beta redis memcached \
#	&& docker-php-ext-enable apcu redis memcached

# PHP configuration
RUN sed -i'.bak' -e 's%\(upload_max_filesize\) = .*M%\1 = 8M%' \
	-e 's%\(session.cookie_httponly\) =.*%\1 = On%' \
	-e 's%\(session.hash_function\) = 0%\1 = 1%' \
	  /etc/php/7.0/apache2/php.ini

#VOLUME /var/www/html
#VOLUME ["/var/log"]

EXPOSE 80 443

CMD ["/sbin/my_init"]
