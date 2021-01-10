FROM cedrik/baseimage:18.04
LABEL org.opencontainers.image.title="TiddlyWiki" \
      org.opencontainers.image.authors="Cédrik LIME"

COPY docker-entrypoint.sh consul-healthcheck.sh  /usr/local/bin/

ARG NODEREPO=node_12.x

# To compile and install native addons from npm you may also need to install build tools: build-essential
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
  && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-transport-https lsb-release curl \
  && echo "deb https://deb.nodesource.com/${NODEREPO} `lsb_release -cs` main" > /etc/apt/sources.list.d/nodesource.list \
  && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends nodejs \
#	&& ln -s /usr/bin/nodejs /usr/bin/node \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& npm install -g --production tiddlywiki \
	# To update: npm update -g tiddlywiki
	&& tiddlywiki --version \
#	&& cd /srv \
#	&& tiddlywiki wiki --init server \
	&& chown -R www-data: /srv

#VOLUME ["/var/log", "/srv"]

EXPOSE 8080

USER www-data

WORKDIR /srv

ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["tiddlywiki"]
