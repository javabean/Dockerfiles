FROM cedrik/baseimage:latest
MAINTAINER Cédrik LIME

RUN mkdir -p /etc/service/openvpn
#RUN ln -sf /bin/sv /etc/init.d/openvpn
COPY runit_openvpn /etc/service/openvpn/run
#COPY runit_openvpn /etc/my_init.d/openvpn

COPY 60-ipsec.conf /etc/sysctl.d/
COPY newClient.sh revokeClient.sh openvpn-status.sh  /usr/local/bin/

ARG EASYRSA_VERSION=3.0.1

#RUN curl -fsSSL https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - \
#	&& echo "deb http://swupdate.openvpn.net/apt <osrelease> main" > /etc/apt/sources.list.d/swupdate.openvpn.net.list
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		openvpn openssl liblzo2-2 iptables kmod ca-certificates bridge-utils \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& curl -fsSL https://github.com/OpenVPN/easy-rsa/releases/download/${EASYRSA_VERSION}/EasyRSA-${EASYRSA_VERSION}.tgz | tar xz -C /usr/local/ \
	&& ln -s /usr/local/EasyRSA-* /usr/local/easy-rsa

#VOLUME ["/etc/openvpn", "/var/log"]

EXPOSE 1194/tcp 1194/udp

#ENTRYPOINT ["/entrypoint.sh"]
#CMD ["openvpn", "--cd /etc/openvpn", "--config server.conf"]
CMD ["/sbin/my_init"]
