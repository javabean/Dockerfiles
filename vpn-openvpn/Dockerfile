FROM cedrik/baseimage:latest
MAINTAINER Cédrik LIME

COPY 60-ipsec.conf /etc/sysctl.d/
COPY docker-entrypoint.sh  /usr/local/bin/
COPY newClient.sh revokeClient.sh openvpn-status.sh  /usr/local/bin/

ARG EASYRSA_VERSION=3.0.1

#RUN curl -fsSL https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - \
#	&& echo "deb http://swupdate.openvpn.net/apt <osrelease> main" > /etc/apt/sources.list.d/swupdate.openvpn.net.list
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		openvpn openssl liblzo2-2 iptables kmod ca-certificates bridge-utils \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& curl -fsSL https://github.com/OpenVPN/easy-rsa/releases/download/${EASYRSA_VERSION}/EasyRSA-${EASYRSA_VERSION}.tgz | tar xz -C /usr/local/ \
	&& ln -s /usr/local/EasyRSA-* /usr/local/easy-rsa

#VOLUME ["/etc/openvpn", "/var/log"]

EXPOSE 1194/tcp 1194/udp

#CMD ["openvpn", "--cd /etc/openvpn", "--config server.conf"]

ENTRYPOINT ["/usr/local/sbin/dumb-init", "--", "/usr/local/bin/docker-entrypoint.sh"]

CMD ["/usr/sbin/openvpn"]
