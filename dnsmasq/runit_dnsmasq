#!/bin/sh

# copy backup of conf dirs if mounted volume is empty
/usr/local/bin/restore_conf.sh

exec /usr/sbin/dnsmasq -k -u dnsmasq --no-dhcp-interface=eth0 --conntrack --conf-file=/etc/dnsmasq.conf --conf-dir='/etc/dnsmasq.d,*.conf,.dpkg-dist,.dpkg-old,.dpkg-new' --domain-needed --stop-dns-rebind --rebind-localhost-ok ${DNSMASQ_EXTRA_OPTS}
