FROM ubuntu:16.04
#FROM armhf/ubuntu:16.04
MAINTAINER Cédrik LIME <info@cedrik.fr>

ARG APT_MIRROR=fr.archive.ubuntu.com
#ARG APT_MIRROR=ports.ubuntu.com/ubuntu-ports

#ENV CONTAINERPILOT=file:///usr/local/etc/containerpilot.json

ADD . /bd_build

RUN /bd_build/prepare.sh && \
	/bd_build/system_services.sh && \
	/bd_build/utilities.sh && \
	/bd_build/cleanup.sh

#VOLUME ["/var/log"]

#ENTRYPOINT ["/usr/local/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]
#ENTRYPOINT ["/usr/local/sbin/dumb-init", "--", "/docker-entrypoint.sh"]
#ENTRYPOINT ["/usr/local/sbin/containerpilot", "--", "/docker-entrypoint.sh"]
#ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/docker-entrypoint.sh"]

ENTRYPOINT ["/usr/local/sbin/docker-init.sh"]
