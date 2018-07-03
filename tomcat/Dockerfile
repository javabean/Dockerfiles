FROM cedrik/java:latest
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Cédrik LIME"

ENV CATALINA_HOME=/usr/local/tomcat
#ENV CATALINA_BASE=...
RUN echo "/usr/local/tomcat" > /etc/container_environment/CATALINA_HOME
#RUN echo "..." > /etc/container_environment/CATALINA_BASE

#RUN ln -sf /bin/sv /etc/init.d/tomcat
COPY runit_tomcat /etc/service/tomcat/run
#COPY runit_tomcat /etc/my_init.d/tomcat

COPY docker-entrypoint.sh consul-healthcheck.sh  /usr/local/bin/

############### FIXME  change version here! ###############
ARG TOMCAT_VERSION=8.5.32

# Create "tomcat" user
RUN	if ! getent group "tomcat" > /dev/null 2>&1 ; then \
		addgroup --system --gid 8080 "tomcat" --quiet ; \
	fi \
	&& if ! id tomcat > /dev/null 2>&1 ; then \
		adduser --system --uid 8080 --home /usr/share/tomcat --no-create-home --ingroup "tomcat" --disabled-password --shell /bin/false --gecos "Tomcat" "tomcat" \
		&& usermod -L tomcat \
		&& usermod -a -G docker_env tomcat ; \
	fi \
\
# Authorize user "tomcat" to open privileged ports via authbind.
	&& TOMCAT_UID="`id -u tomcat`" \
	&& if [ ! -f "/etc/authbind/byuid/$TOMCAT_UID" ]; then \
		if [ ! -d "/etc/authbind/byuid" ]; then \
			mkdir -p /etc/authbind/byuid \
			&& chmod 755 /etc/authbind \
			&& chmod 755 /etc/authbind/byuid ; \
		fi \
		&& if [ ! -d "/etc/authbind/byport" ]; then \
			mkdir -p /etc/authbind/byport \
			&& chmod 755 /etc/authbind \
			&& chmod 755 /etc/authbind/byport ; \
		fi \
		&& echo "0.0.0.0/0,80-80" > /etc/authbind/byuid/$TOMCAT_UID \
		&& echo "0.0.0.0/0,443-443" >> /etc/authbind/byuid/$TOMCAT_UID \
		&& touch /etc/authbind/byport/80 /etc/authbind/byport/443 \
		&& chown tomcat:tomcat /etc/authbind/byuid/$TOMCAT_UID /etc/authbind/byport/80 /etc/authbind/byport/443 \
		&& chmod 700 /etc/authbind/byuid/$TOMCAT_UID /etc/authbind/byport/80 /etc/authbind/byport/443 ; \
	fi

RUN curl -fsSL https://archive.apache.org/dist/tomcat/tomcat-`echo "${TOMCAT_VERSION}"|cut -d '.' -f 1`/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz | tar xz -C /usr/local/ \
	&& ln -s /usr/local/apache-tomcat-* /usr/local/tomcat \
	&& rm -rf /usr/local/tomcat/webapps/docs /usr/local/tomcat/webapps/examples \
	&& cd /usr/local/tomcat/lib/ && curl -fsSLR --remote-name-all https://archive.apache.org/dist/tomcat/tomcat-`echo "${TOMCAT_VERSION}"|cut -d '.' -f 1`/v${TOMCAT_VERSION}/bin/extras/catalina-{ws,jmx-remote}.jar && cd - \
	&& mkdir -p /usr/local/tomcat/lib/org/apache/catalina/util && echo "server.info=Apache Tomcat/42.x" > /usr/local/tomcat/lib/org/apache/catalina/util/ServerInfo.properties \
	&& sed -i'.bak' 's%#\(JAVA_OPTS=.*SecurityListener.UMASK=.*\)$%\1%'  /usr/local/tomcat/bin/catalina.sh \
	&& chgrp -R tomcat /usr/local/tomcat/* \
	&& chown -R tomcat: /usr/local/tomcat/logs /usr/local/tomcat/temp /usr/local/tomcat/work \
	&& chmod -R g+rX /usr/local/tomcat/* \
	&& mkdir -p /opt/tomcat && chown tomcat: /opt/tomcat
#	&& chown -R tomcat:adm /srv/logs/tomcat

#VOLUME ["/var/log"]

EXPOSE 8080 8443

#USER tomcat

ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/usr/local/bin/docker-entrypoint.sh"]
# Can not use env var here...
#CMD ["$CATALINA_HOME/bin/catalina.sh", "run"]
CMD ["run"]
