FROM ubuntu:15.10
MAINTAINER Cédrik LIME <info@cedrik.fr>

ARG APT_MIRROR=fr.archive.ubuntu.com

ADD . /bd_build

RUN /bd_build/prepare.sh && \
	/bd_build/system_services.sh && \
	/bd_build/utilities.sh && \
	/bd_build/cleanup.sh

#ENTRYPOINT ["/usr/local/bin/tini", "-c", "--", "/docker-entrypoint.sh"]
#ENTRYPOINT ["/usr/local/bin/dumb-init", "/docker-entrypoint.sh"]

CMD ["/sbin/my_init"]
