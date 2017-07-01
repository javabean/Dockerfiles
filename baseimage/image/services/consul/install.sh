#!/bin/bash
set -eu -o pipefail -o posix
shopt -s failglob
#set -x
source /bd_build/buildconfig
set -x

CONSUL_ARCH=
if [ "`dpkg --print-architecture | awk -F- '{ print $NF }'`" = "amd64" ]; then
	CONSUL_ARCH="amd64"
elif [ "`dpkg --print-architecture | awk -F- '{ print $NF }'`" = "armhf" ]; then
	CONSUL_ARCH="arm"
else
	echo "ERROR: unknown architecture: `dpkg --print-architecture | awk -F- '{ print $NF }'`"
	exit 1
fi

$minimal_apt_get_install curl ca-certificates unzip authbind libcap2-bin

# Create "consul" user
if ! getent group "consul" > /dev/null 2>&1 ; then
	addgroup --system --gid 8300 "consul" --quiet
fi
if ! id consul > /dev/null 2>&1 ; then
	adduser --system --uid 8300 --home /usr/share/consul --no-create-home --ingroup "consul" --disabled-password --shell /bin/false --gecos "Consul.io" "consul"
	usermod -L consul
	usermod -a -G docker_env consul
fi
# Authorize user "consul" to open privileged ports via authbind.
CONSUL_UID="`id -u consul`"
if [ ! -f "/etc/authbind/byuid/$CONSUL_UID" ]; then
	if [ ! -d "/etc/authbind/byuid" ]; then
		mkdir -p --mode=755 /etc/authbind/byuid
	fi
	if [ ! -d "/etc/authbind/byport" ]; then
		mkdir -p --mode=755 /etc/authbind/byport
	fi
	echo "0.0.0.0/0,53-53" > /etc/authbind/byuid/$CONSUL_UID
	touch /etc/authbind/byport/53
	chown consul:consul /etc/authbind/byuid/$CONSUL_UID /etc/authbind/byport/53
	chmod 700 /etc/authbind/byuid/$CONSUL_UID /etc/authbind/byport/53
fi

curl -fsSL -o /tmp/consul.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_${CONSUL_ARCH}.zip
unzip -q -d /usr/local/bin /tmp/consul.zip
rm /tmp/consul.zip
#curl -fsSL -o /tmp/consul_web_ui.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_web_ui.zip
#mkdir -p /usr/local/share/consul/ui
#unzip -q -d /usr/local/share/consul/ui /tmp/consul_web_ui.zip
#rm /tmp/consul_web_ui.zip
curl -fsSL -o /tmp/consul-template.zip https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_${CONSUL_ARCH}.zip
unzip -q -d /usr/local/bin /tmp/consul-template.zip
rm /tmp/consul-template.zip

# If requested, set the capability to bind to privileged ports before
# we drop to the non-root user. Note that this doesn't work with all
# storage drivers (it won't work with AUFS).
# An alternative would be to use authbind, which unfortunately does not work in Docker...
setcap 'cap_net_bind_service=+ep' /usr/local/bin/consul || true

mkdir -p /srv/consul /tmp/consul/data /usr/local/etc/consul.d
# In a read-only container, only /tmp is writable; no effect if /srv/consul/data is docker-mounted
ln -s /tmp/consul/data /srv/consul/

# default configuration
cp -a /bd_build/services/consul/consul-default.json /usr/local/etc/consul.json
cp -a /bd_build/services/consul/consul-template-default.json /usr/local/etc/consul-template.json
chown -R consul:consul /srv/consul /tmp/consul /usr/local/etc/consul*  /usr/local/etc/consul-template*
cp -a /bd_build/services/consul/consul-entrypoint.sh /usr/local/bin/consul.sh
cp -a /bd_build/services/consul/consul-template-entrypoint.sh /usr/local/bin/consul-template.sh
# runit
mkdir /etc/service/consul
cp -a /bd_build/services/consul/consul.runit /etc/service/consul/run
