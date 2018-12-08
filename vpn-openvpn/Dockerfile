FROM cedrik/baseimage:18.04
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Cédrik LIME"

COPY 60-ipsec.conf /etc/sysctl.d/
COPY docker-entrypoint.sh consul-healthcheck.sh newClient.sh revokeClient.sh openvpn-status.sh  /usr/local/bin/

ARG EASYRSA_VERSION=3.0.5
# stable|testing|release/2.3|release/2.4
ARG OPENVPN_VERSION=stable

# Note: Ubuntu > 16.04 and Debian > 8 have OpenVPN >= 2.4 without the need of a third party repository.
# We choose nonetheless to install the latest version (by picking binary in Xenial repo).

RUN curl -fsSL https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - \
	# https://community.openvpn.net/openvpn/wiki/OpenvpnSoftwareRepos
	# version=stable|testing|release/2.3|release/2.4
	# osrelease=wheezy (Debian 7.x)|jessie (Debian 8.x)|xenial (Ubuntu 16.04)
#	&& echo "deb http://build.openvpn.net/debian/openvpn/${OPENVPN_VERSION} $(lsb_release -cs) main" > /etc/apt/sources.list.d/openvpn-aptrepo.list \
	&& echo "deb http://build.openvpn.net/debian/openvpn/${OPENVPN_VERSION} xenial main" > /etc/apt/sources.list.d/openvpn-aptrepo.list \
	&& apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		debconf libc6 liblz4-1 liblzo2-2 libpam0g libpkcs11-helper1 libssl1.0.0 libssl1.1 libsystemd0 init-system-helpers iproute2 lsb-base \
		openssl liblzo2-2 liblz4-1 iptables kmod ca-certificates bridge-utils \
#		openvpn \
	&& apt-get download openvpn \
	&& dpkg --install --ignore-depends=initscripts openvpn*.deb \
	&& rm openvpn*.deb \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& curl -fsSL https://github.com/OpenVPN/easy-rsa/releases/download/v${EASYRSA_VERSION}/EasyRSA-nix-${EASYRSA_VERSION}.tgz | tar xz -C /usr/local/ \
	&& ln -s /usr/local/EasyRSA-* /usr/local/easy-rsa \
# OpenVPN requires TUN/TAP driver support in the kernel. You'll also need a 
# tun device file. If it's not present on your system, you may create one
# with these commands (as root):
	&& if [ ! -d /dev/net ]; then mkdir -p /dev/net; fi \
	&& if [ ! -c /dev/net/tun ]; then mknod /dev/net/tun c 10 200; fi


#VOLUME ["/etc/openvpn", "/var/log"]

EXPOSE 1194/tcp 1194/udp

#CMD ["openvpn", "--cd /etc/openvpn", "--config server.conf"]

ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/sbin/openvpn"]
