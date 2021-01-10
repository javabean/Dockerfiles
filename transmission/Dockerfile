#FROM ubuntu:latest
FROM cedrik/baseimage:18.04
LABEL org.opencontainers.image.title="Transmission" \
      org.opencontainers.image.authors="Cédrik LIME"

ENV TRANSMISSION_HOME=/var/lib/transmission-daemon

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 365C5CA1 \
	&& echo "deb http://ppa.launchpad.net/transmissionbt/ppa/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/launchpad-transmissionbt.list \
	# transmission-remote-cli requires python, hence is excluded here to save 13 MB; add it to control Transmission daemon from CLI
	&& apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends transmission-daemon transmission-cli curl kmod \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	# remove symbolic link to enable persistent settings.json across container invocations
	&& rm "${TRANSMISSION_HOME}/.config/transmission-daemon/settings.json" \
	&& mv /etc/transmission-daemon/settings.json "${TRANSMISSION_HOME}/.config/transmission-daemon/" \
	&& ln -s "${TRANSMISSION_HOME}/.config/transmission-daemon/settings.json" /etc/transmission-daemon/ \
	&& mv /etc/transmission-daemon/README.json "${TRANSMISSION_HOME}/.config/transmission-daemon/" \
	&& ln -s "${TRANSMISSION_HOME}/.config/transmission-daemon/README.json" /etc/transmission-daemon/ \
	&& mkdir -p "${TRANSMISSION_HOME}/torrents" "${TRANSMISSION_HOME}/incomplete" "${TRANSMISSION_HOME}/downloads" "${TRANSMISSION_HOME}/info/blocklists" \
	&& chown debian-transmission: "${TRANSMISSION_HOME}/torrents" "${TRANSMISSION_HOME}/incomplete" "${TRANSMISSION_HOME}/downloads" "${TRANSMISSION_HOME}/info/blocklists" \
	&& tar czf /var/lib/transmission-daemon.tgz -C /var/lib transmission-daemon

COPY docker-entrypoint.sh consul-healthcheck.sh  /usr/local/bin/

#VOLUME ["/var/lib/transmission-daemon"]

#USER debian-transmission

EXPOSE 9091 51413/tcp 51413/udp

ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/bin/transmission-daemon"]
