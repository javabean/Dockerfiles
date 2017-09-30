ARG DOCKER_FROM=ubuntu:16.04
#ARG DOCKER_FROM=arm32v7/ubuntu:16.04
FROM ${DOCKER_FROM}
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Cédrik LIME"

ARG APT_MIRROR=fr.archive.ubuntu.com
#ARG APT_MIRROR=ports.ubuntu.com/ubuntu-ports

#ENV CONTAINERPILOT=file:///usr/local/etc/containerpilot.json

COPY docker-healthcheck.sh  /usr/local/bin/
COPY . /bd_build

RUN /bd_build/prepare.sh && \
	/bd_build/system_services.sh && \
	/bd_build/utilities.sh && \
	/bd_build/cleanup.sh

ENV DEBIAN_FRONTEND="teletype" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LC_ALL="en_US.UTF-8"

#VOLUME ["/var/log"]

HEALTHCHECK --interval=60s --timeout=10s --retries=3 \
	CMD ["/usr/local/bin/docker-healthcheck.sh"]
# Should you need to disable health checks in an inherited Dockerfile:
#HEALTHCHECK NONE

#ENTRYPOINT ["/usr/local/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]
#ENTRYPOINT ["/usr/local/sbin/dumb-init", "--", "/docker-entrypoint.sh"]
#ENTRYPOINT ["/usr/local/sbin/containerpilot", "--", "/docker-entrypoint.sh"]
#ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/docker-entrypoint.sh"]

ENTRYPOINT ["/usr/local/sbin/docker-init.sh"]
