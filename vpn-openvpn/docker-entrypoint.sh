#!/bin/bash
set -e

PROTOCOL=${PROTOCOL:-udp}
PROTOCOL_SERVER=${PROTOCOL}
PROTOCOL_CLIENT=${PROTOCOL}
if [ "${PROTOCOL}" = "tcp" ]; then
	PROTOCOL_SERVER="tcp-server"
	PROTOCOL_CLIENT="tcp-client"
fi

getIP() {
	# Try to detect a NATed connection
	IP=$(curl -fsSL ipv4.icanhazip.com)
	#IP=$(curl -4fsSL http://whatismyip.akamai.com/)
	#IP=$(curl -fsSL http://myip.enix.org/REMOTE_ADDR)
}

execOpenVPN() {

if [ ! -d /etc/openvpn/easy-rsa ]; then
	cd /etc/openvpn
	cp -a /usr/local/EasyRSA-* .
	ln -s EasyRSA-* easy-rsa
fi

[ -f /etc/openvpn/newClient.sh ] || cp -a /usr/local/bin/newClient.sh /etc/openvpn/
[ -f /etc/openvpn/revokeClient.sh ] || cp -a /usr/local/bin/revokeClient.sh /etc/openvpn/
[ -f /etc/openvpn/openvpn-status.sh ] || cp -a /usr/local/bin/openvpn-status.sh /etc/openvpn/

[ -d /etc/openvpn/clients ] || mkdir /etc/openvpn/clients

if [ ! -d /etc/openvpn/easy-rsa/pki ]; then
	#cd /etc/openvpn
	#[ -f dh.pem ] || openssl dhparam -out dh.pem 2048
	#[ -f key.pem ] || openssl genrsa -out key.pem 2048
	#chmod 600 key.pem
	#[ -f csr.pem ] || openssl req -new -key key.pem -out csr.pem -subj /CN=OpenVPN/
	#[ -f cert.pem ] || openssl x509 -req -in csr.pem -out cert.pem -signkey key.pem -days 36525

	cd /etc/openvpn/easy-rsa/
	# Create the PKI, set up the CA, the DH params and the server + client certificates
	./easyrsa init-pki
	./easyrsa --batch build-ca nopass
	./easyrsa gen-dh
	./easyrsa build-server-full server nopass
#	./easyrsa build-client-full $CLIENT nopass
	./easyrsa gen-crl
	# Ensure "nobody" can read the CRL
	chmod a+r pki/crl.pem
	chmod a+x pki
	# Move the stuff we need
	cd ..
	ln -sf easy-rsa/pki/ca.crt easy-rsa/pki/dh.pem easy-rsa/pki/issued/server.crt easy-rsa/pki/private/server.key easy-rsa/pki/crl.pem  .
fi

[ -f /etc/openvpn/ta.key ] || openvpn --genkey --secret /etc/openvpn/ta.key
chmod 600 /etc/openvpn/ta.key

if [ ! -f /etc/openvpn/server.conf ]; then

	getIP

	# Generate server.conf
	cat <<- EOF > /etc/openvpn/server.conf
# Tunnel Options
proto ${PROTOCOL_SERVER}
port 1194
dev tun
topology subnet
;tun-ipv6
;tun-mtu 12000 # default 1500
;fragment 0
;mssfix 0
# Common values to try for mssfix/fragment: 1200, 1300, or 1400
# Note however that fragment will exact a performance penalty.
# Note that while mssfix only needs to be specified on one side of the connection, fragment should be specified on both.
;mssfix 1450
;fragment 1450
sndbuf 0
rcvbuf 0
keepalive 10 120
ping-timer-rem
persist-tun
persist-key
;script-security 1
user nobody
# nogroup (debian)|nobody (CentOS)
group nogroup
;errors-to-stderr
;fast-io
# Set the appropriate level of log
# file verbosity.
#
# 0 is silent, except for fatal errors
# 4 is reasonable for general usage
# 5 and 6 can help to debug connection problems
# 9 is extremely verbose
verb 4
# Silence repeating messages.
mute 20
;status /dev/stdout # Can also send SIGUSR2 to output connection statistics to log file or syslog
;compress lz4
comp-lzo
# https://github.com/OpenVPN/openvpn/blob/master/doc/management-notes.txt
management localhost 7505 # use telnet!

# Server Mode
#server 10.66.77.0 255.255.255.0
server 10.8.0.0 255.255.255.0
# Enable client access to Docker containers
#push "route 172.17.0.0 255.255.0.0"
push "sndbuf 0"
push "rcvbuf 0"
# force all traffic through VPN
;push "redirect-gateway autolocal def1 ipv6 bypass-dhcp"
push "redirect-gateway autolocal def1 bypass-dhcp"
;push "compress lz4"
push "comp-lzo"
push "dhcp-option PROXY_HTTP 172.31.53.28 3128"
#push "dhcp-option PROXY_HTTPS 172.31.53.28 3128"
#push "dhcp-option PROXY_BYPASS example1.tld example2.tld example3.tld"
#push "dhcp-option PROXY_AUTO_CONFIG_URL https://www.cedrik.fr/proxy.pac"
EOF
	# DNS
	# Obtain the resolvers from resolv.conf and use them for OpenVPN
	if [ ! -z "${DNS_USE_RESOLVCONF}" ]; then
		grep -v '#' /etc/resolv.conf | grep 'nameserver' | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | while read line; do
			echo "push \"dhcp-option DNS $line\"" >> /etc/openvpn/server.conf
		done
	fi
	[ ! -z "$DNS_EXTRA_SERVER_1" ] && echo "push \"dhcp-option DNS ${DNS_EXTRA_SERVER_1}\"" >> /etc/openvpn/server.conf
	[ ! -z "$DNS_EXTRA_SERVER_2" ] && echo "push \"dhcp-option DNS ${DNS_EXTRA_SERVER_2}\"" >> /etc/openvpn/server.conf
	cat <<- EOF >> /etc/openvpn/server.conf
ifconfig-pool-persist ipp.txt
;client-to-client
max-clients 100
opt-verify

# Data Channel Encryption Options
# openvpn --show-digests
;auth SHA1    # default
;auth SHA256
# openvpn --show-ciphers
;cipher BF-CBC        # Blowfish (default; do not use: Sweet32)
cipher AES-128-CBC   # AES cipher algorithm is well-suited for the ARM processor
;cipher DES-EDE3-CBC  # Triple-DES (do not use: Sweet32)
;cipher AES-128-GCM
;cipher AES-256-GCM
# openvpn --show-engines
;engine [engine-name]

# TLS Mode Options
ca ca.crt
dh dh.pem
cert server.crt
key server.key  # This file should be kept secret
# If your clients and servers are modern (2.3.3+), they should support TLSv1.2 just fine
# Note that this will break OpenVPN versions 2.3.2 and earlier, which only expect TLSv1.0 handshake signatures.
;tls-version-min 1.2 or-highest
;tls-version-min 1.2
# openvpn --show-tls
;tls-cipher TLS-DHE-RSA-WITH-AES-128-GCM-SHA256
;tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384
;tls-cipher TLS-ECDHE-RSA-WITH-AES-128-GCM-SHA256:TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256:TLS-ECDHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256
tls-exit
tls-auth ta.key 0 # This file is secret
remote-cert-tls client
crl-verify crl.pem
EOF

fi

if [ ! -f /etc/openvpn/client-common.txt ]; then

	getIP

	# client-common.txt is created so we have a template to add further users later
	cat <<- EOF > /etc/openvpn/client-common.txt
# Tunnel Options
remote $IP 1194
;remote $IP 1194 udp
;remote $IP 443 tcp-client
;remote-random
proto ${PROTOCOL_CLIENT}
;http-proxy [proxy server] [proxy port]
;http-proxy-retry # retry on connection failures
;http-proxy-option AGENT "OpenVPN User-Agent"
;socks-proxy server [port]
resolv-retry infinite
nobind
dev tun
# force all traffic through VPN; pushed from server
;redirect-gateway autolocal def1 ipv6 bypass-dhcp
;redirect-gateway autolocal def1 bypass-dhcp
;tun-mtu 12000 # default 1500
;fragment 0
;mssfix 0
sndbuf 0
rcvbuf 0
;keepalive 10 60 # pushed by server
ping-timer-rem
persist-tun
persist-key
# Set log file verbosity.
verb 2
# Silence repeating messages
mute 20
;compress lz4
comp-lzo

# Server Mode
push-peer-info

# Client Mode
client

# Data Channel Encryption Options
key-direction 1 # since tls-auth is inline
# openvpn --show-digests
;auth SHA1    # default
;auth SHA256
# openvpn --show-ciphers
;cipher BF-CBC        # Blowfish (default; do not use: Sweet32)
cipher AES-128-CBC   # AES cipher algorithm is well-suited for the ARM processor
;cipher DES-EDE3-CBC  # Triple-DES (do not use: Sweet32)
;cipher AES-128-GCM
;cipher AES-256-GCM
# common false alarm on WiFi networks
mute-replay-warnings

# TLS Mode Options
;ca
;cert
;key
# If your clients and servers are modern (2.3.3+), they should support TLSv1.2 just fine
# Note that this will break OpenVPN versions 2.3.2 and earlier, which only expect TLSv1.0 handshake signatures.
;tls-version-min 1.2 or-highest
;tls-version-min 1.2
# openvpn --show-tls
;tls-cipher TLS-DHE-RSA-WITH-AES-128-GCM-SHA256
;tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384
;tls-cipher TLS-ECDHE-RSA-WITH-AES-128-GCM-SHA256:TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256:TLS-ECDHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256
tls-exit
;tls-auth ta.key 1
;ns-cert-type server # Netscape extensions are deprecated
remote-cert-tls server

# Windows-Specific Options
setenv opt block-outside-dns
EOF

fi


# enable IP forwarding
# disabled in Docker since: Read-only file system
#echo 1 > /proc/sys/net/ipv4/ip_forward
#sysctl -w net.ipv4.ip_forward=1
#sysctl -w net.ipv6.conf.default.forwarding=1
#  Enabling this option disables Stateless Address Autoconfiguration
#  based on Router Advertisements for this host
#sysctl -w net.ipv6.conf.all.forwarding=1

# If any of your VPNs uses "dev tun" and "topology subnet" but does not use
# "client-to-client", OpenVPN's init.d script will disable all.send_redirects
# (set it to 0) to avoid sending ICMP redirects trough the tun interfaces (and
# confusing clients).
# When using "client-to-client", OpenVPN routes the traffic itself without
# involving the TUN/TAP interface so no ICMP redirects are sent
# disabled in Docker since: Read-only file system
#echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
#sysctl -w net.ipv4.conf.all.send_redirects=0


# OpenVPN requires TUN/TAP driver support in the kernel. You'll also need a 
# tun device file. If it's not present on your system, you may create one
# with these commands (as root):
[ -d /dev/net ] || mkdir -p /dev/net
[ -c /dev/net/tun ] || mknod /dev/net/tun c 10 200
if [ ! -e /dev/net/tun ]; then
	echo "TUN/TAP is not available"
	exit 2
fi

modprobe -v tun

# configure firewall

# Set NAT for the VPN subnet
IP=`sed '/^remote /!d;s/remote \(.*\) 1194/\1/' /etc/openvpn/client-common.txt`
#IP=`/sbin/ifconfig eth0 | grep "inet" | head -n1 | awk '{ print $2}' | cut -d: -f2`
#iptables -t nat -C POSTROUTING -s 10.8.0.0/24 -j SNAT --to $IP || {
#	iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to $IP
#}
iptables -t nat -C POSTROUTING -s 10.8.0.0/24 -o eth+ -j MASQUERADE || {
	iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth+ -j MASQUERADE
}
iptables -C INPUT -p ${PROTOCOL} --dport 1194 -j ACCEPT || {
	iptables -A INPUT -p ${PROTOCOL} --dport 1194 -j ACCEPT
}
iptables -C FORWARD -s 10.8.0.0/24 -j ACCEPT || {
	iptables -A FORWARD -s 10.8.0.0/24 -j ACCEPT
}
# Allow TUN interface connections to OpenVPN server
iptables -C INPUT -i tun+ -j ACCEPT || {
	iptables -A INPUT -i tun+ -j ACCEPT
}
# Allow TUN interface connections to be forwarded through other interfaces
iptables -C FORWARD -i tun+ -j ACCEPT || {
	iptables -A FORWARD -i tun+ -j ACCEPT
}
# Allow TAP interface connections to OpenVPN server
#iptables -C INPUT -i tap+ -j ACCEPT || {
#	iptables -A INPUT -i tap+ -j ACCEPT
#}
# Allow TAP interface connections to be forwarded through other interfaces
#iptables -C FORWARD -i tap+ -j ACCEPT || {
#	iptables -A FORWARD -i tap+ -j ACCEPT
#}
# Force HTTP proxy; commented out since it is pushed to client
#iptables -t nat -C PREROUTING -s 10.8.0.0/16 -p tcp --dport 80 -j DNAT --to-destination 172.31.31.28:3128 || {
#	iptables -t nat -A PREROUTING -s 10.8.0.0/16 -p tcp --dport 80 -j DNAT --to-destination 172.31.31.28:3128
#}


mkdir -p /run/openvpn

exec "$@" --writepid /run/openvpn/server.pid --cd /etc/openvpn --config /etc/openvpn/server.conf ${OPENVPN_OPTS}

}




# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "${1:0:1}" = '-' ]; then
    set -- openvpn "$@"
fi

# check for the expected command
if [ "$1" = 'openvpn' -o "$1" = '/usr/sbin/openvpn' ]; then
	execOpenVPN "$@"
fi

# else default to run whatever the user wanted like "bash"
exec "$@"
