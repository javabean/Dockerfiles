FROM cedrik/baseimage:18.04
LABEL org.opencontainers.image.authors="Cédrik LIME"

#RUN ln -sf /bin/sv /etc/init.d/postfix
#RUN ln -sf /bin/sv /etc/init.d/opendkim
COPY runit_postfix /etc/service/postfix/run
#COPY runit_postfix /etc/my_init.d/postfix
COPY runit_opendkim /etc/service/opendkim/run
#COPY runit_opendkim /etc/my_init.d/opendkim

ARG POSTFIX_HOSTNAME=myhost.example.net

COPY dkim_new_domain.sh dkim-stats.sh consul-healthcheck.sh  /usr/local/bin/

# unattended installs an "Internet" profile
RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends postfix opendkim opendkim-tools \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
# disable chroot for postfix smtp daemon
# http://www.postfix.org/INSTALL.html#hamlet
#	&& ln -nf /etc/services /var/spool/postfix/etc/services \
#	&& sed -i'.bak' -e 's/^\(smtp\s*unix\s*-\s*-\s*\)-\(\s*-\s*-\s*smtp\)/\1n\2/' -e 's/^\(relay\s*unix\s*-\s*-\s*\)-\(\s*-\s*-\s*smtp\)/\1n\2/'  /etc/postfix/master.cf \
#	&& sed -i'.bak' -e 's/^\(smtp\s*unix\s*-\s*-\s*\)y\(\s*-\s*-\s*smtp\)/\1n\2/' -e 's/^\(relay\s*unix\s*-\s*-\s*\)y\(\s*-\s*-\s*smtp\)/\1n\2/'  /etc/postfix/master.cf \
	&& postconf -F smtp/unix/chroot=n relay/unix/chroot=n \
	&& echo 'Include /etc/opendkim-add.conf' >> /etc/opendkim.conf \
	&& mkdir -p /var/run/opendkim /var/spool/postfix/var/run/opendkim \
	&& chown opendkim: /var/run/opendkim /var/spool/postfix/var/run/opendkim \
	&& mkdir -p /usr/local/etc/dkim/keys \
	&& touch /usr/local/etc/dkim/TrustedHosts /usr/local/etc/dkim/KeyTable /usr/local/etc/dkim/SigningTable \
	&& echo "127.0.0.1\nlocalhost\n192.168.0.0/16\n172.16.0.0/12\n10.0.0.0/8" > /usr/local/etc/dkim/TrustedHosts \
	&& chown -R opendkim:postfix /usr/local/etc/dkim

COPY postfix-main.cf /etc/postfix/main.cf
COPY opendkim-add.conf /etc/

RUN sed -i'' -e "s/__POSTFIX_HOSTNAME__/${POSTFIX_HOSTNAME}/" /etc/postfix/main.cf

#VOLUME ["/var/log"]

EXPOSE 25

# AFAIK postfix needs syslog
ENTRYPOINT ["/usr/local/sbin/docker-init.sh"]
# postfix start-fg
# /usr/lib/postfix/master
