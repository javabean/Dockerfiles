FROM cedrik/baseimage:18.04
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Cédrik LIME"

COPY docker-entrypoint.sh consul-healthcheck.sh  /usr/local/bin/

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends libwrap0 libconfig9 sslh iptables iproute2 \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& setcap 'cap_net_bind_service,cap_net_admin+pe' `which sslh` \
	&& setcap 'cap_net_bind_service,cap_net_admin+pe' `which sslh-select`

#VOLUME ["/var/log", "/srv"]

EXPOSE 443

#USER sslh

#WORKDIR /srv

ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["sslh-select"]
