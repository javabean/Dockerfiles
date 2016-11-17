#FROM ubuntu:latest
FROM cedrik/baseimage:latest
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Cédrik LIME"

ENV TRANSMISSION_HOME=/var/lib/transmission-daemon

COPY docker-entrypoint.sh  /usr/local/bin/

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends transmission-daemon curl \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	# remove symbolic link to enable persistent settings.json across container invocations
	&& rm "${TRANSMISSION_HOME}/.config/transmission-daemon/settings.json" \
	&& ln /etc/transmission-daemon/settings.json "${TRANSMISSION_HOME}/.config/transmission-daemon/" \
	&& ln /etc/transmission-daemon/README.json "${TRANSMISSION_HOME}/.config/transmission-daemon/" \
	&& mkdir -p "${TRANSMISSION_HOME}/torrents" "${TRANSMISSION_HOME}/incomplete" "${TRANSMISSION_HOME}/downloads" "${TRANSMISSION_HOME}/info/blocklists" \
	&& chown debian-transmission: "${TRANSMISSION_HOME}/torrents" "${TRANSMISSION_HOME}/incomplete" "${TRANSMISSION_HOME}/downloads" "${TRANSMISSION_HOME}/info/blocklists" \
	&& tar czf /var/lib/transmission-daemon.tgz -C /var/lib transmission-daemon

#VOLUME ["/var/lib/transmission-daemon"]

USER debian-transmission

EXPOSE 9091 51413/tcp 51413/udp

ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/bin/transmission-daemon"]
