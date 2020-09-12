#FROM php:7.2-apache
FROM cedrik/httpd-base:latest
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Cédrik LIME"

############### FIXME  change depending on base OS / version! ###############
ARG MYSQL_VERSION=5.7

# http://dev.mysql.com/doc/refman/5.7/en/checking-gpg-signature.html
#RUN gpg --keyserver keys.gnupg.net --recv-keys 5072E1F5 \
#	&& gpg --export -a 5072E1F5 | apt-key add -
# If behind a restrictive firewall, use: apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --keyserver-options http-proxy="http://<username>:<password>@<proxy_server_addr>:<proxy_port>" --recv-keys 5072E1F5
RUN apt-key adv --keyserver ipv4.pool.sks-keyservers.net --recv-keys 5072E1F5

RUN echo "deb https://repo.mysql.com/apt/ubuntu/ `lsb_release -cs` mysql-${MYSQL_VERSION}" > /etc/apt/sources.list.d/mysql.list

RUN LC_ALL=C.UTF-8  add-apt-repository -y ppa:ondrej/php \
	&& apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	curl bzip2 openssl file \
	libapache2-mod-php7.2 libapache2-mod-bw libapache2-mod-rpaf \
#	libapache2-mod-security2 \
	php7.2-fpm \
	php7.2-gd php7.2-json php7.2-curl php7.2-intl  php7.2-imagick \
	php7.2 php7.2-cli php7.2-readline php7.2-sqlite3 \
	php7.2-apcu php7.2-memcache php7.2-memcached php7.2-redis \
	php7.2-bz2 php7.2-mbstring php7.2-soap php7.2-xml php7.2-zip \
#	php7.2-fpm php7.2-ldap \
	php7.2-mysql mysql-client=${MYSQL_VERSION}.* mysql-common=${MYSQL_VERSION}.* \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& a2dismod mpm_event && a2enmod mpm_prefork \
	&& a2dismod -f deflate \
	# php-fpm: a2enmod proxy_fcgi setenvif && a2enconf php7.2-fpm
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
	  /etc/php/7.2/apache2/php.ini

#VOLUME /var/www/html
#VOLUME ["/var/log"]

EXPOSE 80 443
