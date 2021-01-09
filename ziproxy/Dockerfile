FROM cedrik/baseimage:18.04
LABEL org.opencontainers.image.authors="Cédrik LIME"

COPY docker-entrypoint.sh consul-healthcheck.sh  /usr/local/bin/

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ziproxy \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& mkdir -p /var/log/ziproxy && chown ziproxy:ziproxy /var/log/ziproxy \
	&& sed -i'.bak' \
		-e 's/^#*\s*\(Port =\) .*/\1 3128/' \
		-e 's/^#*\s*\(Address = .*\)/#\1/' \
#		-e 's/^#*\s*\(AccessLog = .*\)/\1/' \
#		-e 's/^#*\s*\(AuthMode =\) .*/\1 1/' \
#		-e 's/^#*\s*\(AuthPasswdFile = .*\)/\1/' \
		-e 's/^#*\s*\(TransparentProxy =\) .*/\1 true/' \
		-e 's/^#*\s*\(OverrideAcceptEncoding =\) .*/\1 false/' \
		-e 's/^#*\s*\(DecompressIncomingGzipData =\) .*/\1 false/' \
#		-e 's/^#*\s*\(ViaServer =\) .*/\1 "http-image-proxy"/' \
		-e 's/^#*\s*\(MaxSize =\) .*/\1 10485760/' \
#		-e 's/^#*\s*\(UseContentLength =\) .*/\1 true/' \
		-e 's/^#*\s*\(ImageQuality =\) .*/\1 {90,90,90,90}/' \
		/etc/ziproxy/ziproxy.conf

#VOLUME ["/var/log"]

#USER ziproxy

EXPOSE 3128

ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/bin/ziproxy"]
