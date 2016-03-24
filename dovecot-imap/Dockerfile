FROM cedrik/baseimage:latest
MAINTAINER Cédrik LIME

RUN mkdir -p /etc/service/dovecot /opt/dovecot
#RUN ln -sf /bin/sv /etc/init.d/dovecot
COPY runit_dovecot /etc/service/dovecot/run
#COPY runit_dovecot /etc/my_init.d/dovecot
#COPY runit_dovecot_log /etc/service/dovecot/log/run

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends dovecot-imapd dovecot-managesieved \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
#	&& sed -i'.bak' -e 's/^\(\!include auth-system.conf.ext\)/#\1/' -e 's/^#*\(\!include auth-passwdfile.conf.ext\)/\1/' /etc/dovecot/conf.d/10-auth.conf \
	&& sed -i'.bak' -e 's/^\(\!include auth-system.conf.ext\)/#\1/' /etc/dovecot/conf.d/10-auth.conf \
	&& sed -i'.bak' \
		-e 's/^#*\(ssl =\) no/\1 yes/' \
		-e 's/^#*\(ssl_dh_parameters_length =\) 1024/\1 2048/' \
		-e 's/^#*\(ssl_protocols = !SSLv2\)$/\1 !SSLv3/' \
		/etc/dovecot/conf.d/10-ssl.conf \
	&& ln -s /opt/dovecot/local.conf /etc/dovecot/ \
	&& ln -s /opt/dovecot/passwd /etc/dovecot/users

#VOLUME ["/opt/dovecot" "/var/log"]

EXPOSE 143 993 4190

#ENTRYPOINT /usr/sbin/dovecot
#CMD ["-F", "-c", "/etc/dovecot/dovecot.conf"]
CMD ["/sbin/my_init"]
