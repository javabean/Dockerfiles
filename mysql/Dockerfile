#FROM mysql/mysql-server:5.7
FROM cedrik/baseimage:latest
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Cédrik LIME"

# http://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/

############### FIXME  change depending on base OS / version! ###############
ARG MYSQL_VERSION=5.6

ENV MYSQL_ALLOW_EMPTY_PASSWORD=yes
RUN echo "yes" > /etc/container_environment/MYSQL_ALLOW_EMPTY_PASSWORD

#RUN ln -sf /bin/sv /etc/init.d/mysql
COPY runit_mysql /etc/service/mysql/run
#COPY runit_mysql /etc/my_init.d/mysql

# http://dev.mysql.com/downloads/repo/apt/
# requires user interaction...
#RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
#	wget \
#	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
#	&& curl -ORL http://dev.mysql.com/get/mysql-apt-config_0.7.2-1_all.deb \
#	&& dpkg -i mysql-apt-config_0.7.2-1_all.deb
#	&& rm mysql-apt-config_0.7.2-1_all.deb
# Selecting a Major Release Version:
#RUN dpkg-reconfigure mysql-apt-config

# http://dev.mysql.com/doc/refman/5.7/en/checking-gpg-signature.html
#RUN gpg --keyserver keys.gnupg.net --recv-keys 5072E1F5 \
#	&& gpg --export -a 5072E1F5 | apt-key add -
RUN apt-key adv --keyserver pgp.mit.edu --recv-keys 5072E1F5

RUN echo "deb http://repo.mysql.com/apt/ubuntu/ `lsb_release --codename | cut -f 2` mysql-${MYSQL_VERSION}" > /etc/apt/sources.list.d/mysql.list

#RUN debconf-set-selections <<< 'mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD'
#RUN echo mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD | debconf-set-selections
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	mysql-server=${MYSQL_VERSION}.* mysql-client=${MYSQL_VERSION}.* mysql-common=${MYSQL_VERSION}.* mysql-utilities mysqltuner \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& usermod -a -G docker_env mysql \
	&& sed -i'.bak' 's%\(bind-address\) = 127.0.0.1%\1 = *%'  /etc/mysql/mysql.conf.d/mysqld.cnf

ADD https://raw.githubusercontent.com/mysql/mysql-docker/mysql-server/${MYSQL_VERSION}/docker-entrypoint.sh  /entrypoint.sh
RUN chmod +x /entrypoint.sh \
	&& mkdir /docker-entrypoint-initdb.d \
# /entrypoint.sh can only init an empty (non-existent) DB
	&& rm -r /var/lib/mysql/*

COPY init-db.sql.sample /docker-entrypoint-initdb.d/
COPY logrotate-mysql-dump /etc/logrotate.d/mysql-dump
#RUN touch /srv/dump.sql.gz

#VOLUME ["/var/lib/mysql", "/srv", "/var/log"]

EXPOSE 3306

#ENTRYPOINT ["/entrypoint.sh"]
#CMD ["mysqld"]
ENTRYPOINT ["/usr/local/sbin/docker-init.sh"]
