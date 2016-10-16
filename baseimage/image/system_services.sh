#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

## Install init process.
cp -a /bd_build/bin/my_init /sbin/
mkdir -p /etc/my_init.d
mkdir -p /etc/container_environment
touch /etc/container_environment.sh
touch /etc/container_environment.json
chmod 700 /etc/container_environment

$minimal_apt_get_install curl ca-certificates tar unzip jq authbind

if [ "`dpkg --print-architecture | awk -F- '{ print $NF }'`" = "amd64" ]; then

if [ -z "${TINI_VERSION}" -o "${TINI_VERSION}" = "latest" ]; then
	TAG_NAME="$(curl -fsSL https://api.github.com/repos/krallin/tini/releases/latest | jq --raw-output '.tag_name')"
	echo "Downloading Tini $TAG_NAME"
	curl -o /usr/local/bin/tini -fsSLR $(curl -fsSL https://api.github.com/repos/krallin/tini/releases/latest | jq --raw-output '.assets[] | select(.name == "tini") | .browser_download_url')
else
	#curl -o /usr/local/bin/tini -fsSLR https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static
	curl -o /usr/local/bin/tini -fsSLR https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini
fi
chmod +x /usr/local/bin/tini*
if [ -z "${DUMB_INIT_VERSION}" -o "${DUMB_INIT_VERSION}" = "latest" ]; then
	TAG_NAME="$(curl -fsSL https://api.github.com/repos/Yelp/dumb-init/releases/latest | jq --raw-output '.tag_name')"
	echo "Downloading dumb-init $TAG_NAME"
	curl -o /usr/local/bin/dumb-init -fsSLR $(curl -fsSL https://api.github.com/repos/Yelp/dumb-init/releases/latest | jq --raw-output ".assets[] | select(.name == \"dumb-init_${TAG_NAME:1}_amd64\") | .browser_download_url")
else
	curl -o /usr/local/bin/dumb-init -fsSLR https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_amd64
fi
chmod +x /usr/local/bin/dumb-init
#if [ -z "${CONTAINERPILOT_VERSION}" -o "${CONTAINERPILOT_VERSION}" = "latest" ]; then
#	TAG_NAME="$(curl -fsSL https://api.github.com/repos/joyent/containerpilot/releases/latest | jq --raw-output '.tag_name')"
#	echo "Downloading ContainerPilot $TAG_NAME"
#	curl -fsSL $(curl -fsSL https://api.github.com/repos/joyent/containerpilot/releases/latest | jq --raw-output ".assets[] | select(.name == \"containerpilot-${TAG_NAME}.tar.gz\") | .browser_download_url") | tar xz -C /usr/local/bin
#else
#	curl -fsSL https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VERSION}/containerpilot-${CONTAINERPILOT_VERSION}.tar.gz | tar xz -C /usr/local/bin
#fi

elif [ "`dpkg --print-architecture | awk -F- '{ print $NF }'`" = "armhf" ]; then
	cp -a /bd_build/bin/dumb-init.armhf  /usr/local/bin/dumb-init
else
	echo "ERROR: unknown architecture: `dpkg --print-architecture | awk -F- '{ print $NF }'`"
	exit 1
fi

groupadd -g 8377 docker_env
chown :docker_env /etc/container_environment.sh /etc/container_environment.json
chmod 640 /etc/container_environment.sh /etc/container_environment.json
ln -s /etc/container_environment.sh /etc/profile.d/

## Install runit.
$minimal_apt_get_install runit

## Install a syslog daemon and logrotate.
[ "$DISABLE_SYSLOG" -eq 0 ] && /bd_build/services/syslog-ng/syslog-ng.sh || true

## Install the SSH server.
[ "$DISABLE_SSH" -eq 0 ] && /bd_build/services/sshd/sshd.sh || true

## Install cron daemon.
[ "$DISABLE_CRON" -eq 0 ] && /bd_build/services/cron/cron.sh || true

# Install Consul & Consul-template
[ "$DISABLE_CONSUL" -eq 0 ] && /bd_build/services/consul/install.sh || true


## Create a user for the web app.
addgroup --gid 9999 app
adduser --uid 9999 --gid 9999 --disabled-password --gecos "Application" app
usermod -L app
usermod -a -G docker_env app
mkdir -p /home/app/.ssh
chmod 700 /home/app/.ssh
chown app:app /home/app/.ssh

