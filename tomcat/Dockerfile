############### FIXME  change version here! ###############
ARG DOCKER_FROM_VERSION=9-jre11-slim

FROM tomcat:${DOCKER_FROM_VERSION}
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Cédrik LIME"

# Create "tomcat" user
RUN	if ! getent group "tomcat" > /dev/null 2>&1 ; then \
		addgroup --system --gid 8080 "tomcat" --quiet ; \
	fi \
	&& if ! id tomcat > /dev/null 2>&1 ; then \
		adduser --system --uid 8080 --home /usr/share/tomcat --no-create-home --ingroup "tomcat" --disabled-password --shell /bin/false --gecos "Tomcat" "tomcat" \
		&& usermod -L tomcat ; \
	fi

# Install procps & curl (for health check)
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-utils && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends procps curl \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## make the "en_US.UTF-8" locale so tomcat will be utf-8 enabled by default
#RUN set -eux; \
#	if [ -f /etc/dpkg/dpkg.cfg.d/docker ]; then \
## if this file exists, we're likely in "debian:xxx-slim", and locales are thus being excluded so we need to remove that exclusion (since we need locales)
#		grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
#		sed -ri '/\/usr\/share\/locale/d' /etc/dpkg/dpkg.cfg.d/docker; \
#		! grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
#	fi; \
#	apt-get update; DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends locales; rm -rf /var/lib/apt/lists/*; \
#	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
#ENV LANG en_US.utf8

RUN rm -rf /usr/local/tomcat/webapps/docs /usr/local/tomcat/webapps/examples \
	&& mkdir -p /usr/local/tomcat/lib/org/apache/catalina/util && echo "server.info=Apache Tomcat/42.x" > /usr/local/tomcat/lib/org/apache/catalina/util/ServerInfo.properties \
	&& chown -R tomcat: /usr/local/tomcat/logs /usr/local/tomcat/temp /usr/local/tomcat/work
# This costs a lot of layer disk space (12m!), so skip it as it is not essential: chgrp -R tomcat /usr/local/tomcat/*

COPY docker-entrypoint.sh docker-healthcheck.sh  /usr/local/bin/

HEALTHCHECK --interval=60s --timeout=10s --start-period=60s --retries=3 \
	CMD ["/usr/local/bin/docker-healthcheck.sh"]

EXPOSE 8080 8443

USER tomcat

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]
