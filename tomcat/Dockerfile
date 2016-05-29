FROM cedrik/java:latest
MAINTAINER Cédrik LIME

ENV CATALINA_HOME=/usr/local/tomcat
#ENV CATALINA_BASE=...
RUN echo "/usr/local/tomcat" > /etc/container_environment/CATALINA_HOME
#RUN echo "..." > /etc/container_environment/CATALINA_BASE

RUN mkdir -p /etc/service/tomcat /opt/tomcat
#RUN ln -sf /bin/sv /etc/init.d/tomcat
COPY runit_tomcat /etc/service/tomcat/run
#COPY runit_tomcat /etc/my_init.d/tomcat

COPY docker-entrypoint.sh  /usr/local/bin/

############### FIXME  change version here! ###############
ARG TOMCAT_VERSION=7.0.69

# Create "tomcat" user
RUN	if ! getent group "tomcat" > /dev/null 2>&1 ; then \
		addgroup --system --gid 8080 "tomcat" --quiet ; \
	fi \
	&& if ! id tomcat > /dev/null 2>&1 ; then \
		adduser --system --uid 8080 --home /usr/share/tomcat --no-create-home --ingroup "tomcat" --disabled-password --shell /bin/false --gecos "Tomcat" "tomcat" \
		&& usermod -L tomcat \
		&& usermod -a -G docker_env tomcat ; \
	fi \
#	&& chown -R tomcat:adm /srv/logs/tomcat
\
# Authorize user "tomcat" to open privileged ports via authbind.
	&& TOMCAT_UID="`id -u tomcat`" \
	&& if [ ! -f "/etc/authbind/byuid/$TOMCAT_UID" ]; then \
		if [ ! -d "/etc/authbind/byuid" ]; then \
			mkdir -p /etc/authbind/byuid \
			&& chmod 755 /etc/authbind \
			&& chmod 755 /etc/authbind/byuid ; \
		fi \
		&& echo '0.0.0.0/0:1,1023' > /etc/authbind/byuid/$TOMCAT_UID \
		&& chown tomcat:tomcat /etc/authbind/byuid/$TOMCAT_UID \
		&& chmod 700 /etc/authbind/byuid/$TOMCAT_UID ; \
	fi

RUN curl -fsSL http://www.eu.apache.org/dist/tomcat/tomcat-7/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz | tar xz -C /usr/local/ \
	&& ln -s /usr/local/apache-tomcat-* /usr/local/tomcat \
	&& rm -r /usr/local/tomcat/webapps/docs /usr/local/tomcat/webapps/examples

#VOLUME ["/var/log"]

EXPOSE 8080 8443

USER tomcat

#ENTRYPOINT ["/usr/local/bin/dumb-init", "/usr/local/bin/docker-entrypoint.sh"]
ENTRYPOINT ["/usr/local/bin/tini", "-g", "--", "/usr/local/bin/docker-entrypoint.sh"]
#ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Can not use env var here...
#CMD ["$CATALINA_HOME/bin/catalina.sh", "run"]
CMD ["run"]

#CMD ["/sbin/my_init"]
