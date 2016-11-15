FROM cedrik/baseimage:latest
MAINTAINER Cédrik LIME

COPY docker-entrypoint.sh  /usr/local/bin/

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends curl jq nodejs git  zlib1g-dev uuid-dev libmnl-dev gcc make git autoconf autoconf-archive autogen automake pkg-config  netcat python python-yaml \
	&& curl -fsSLR -o /tmp/kickstart.sh "https://raw.githubusercontent.com/firehol/netdata-demo-site/master/install-required-packages.sh" \
	&& bash /tmp/kickstart.sh netdata \
#	&& bash /tmp/kickstart.sh netdata-all \
	&& git clone --depth=1 https://github.com/firehol/netdata.git /usr/src/netdata.git \
	&& cd /usr/src/netdata.git \
	&& ./netdata-installer.sh --dont-wait --dont-start-it \
	&& cd - \
	&& apt-get purge -y --auto-remove zlib1g-dev uuid-dev libmnl-dev gcc make git autoconf autoconf-archive autogen automake pkg-config \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& rm -r /usr/src/netdata.git \
	&& sed -i'.bak' \
		# prevent double compression of output (we are running behind a reverse proxy)
		-e 's/^\(\s*\)#*\s*\(enable web responses gzip compression\) = .*/\1\2 = no/' \
		# prevent double access.log
		-e 's/^\(\s*\)#*\s*\(access log \) = .*/\1\2 = none/' \
		-e 's/^\(\s*\)#*\s*\(debug log \) = .*/\1\2 = none/' \
		-e 's@^\(\s*\)#*\s*\(error log \) = .*@\1\2 = /dev/stderr@' \
		-e 's/^\(\s*\)#*\s*\(memory mode \) = .*/\1\2 = ram/' \
		-e 's/^\(\s*\)#*\s*\(multi threaded web server \) = .*/\1\2 = no/' \
		/etc/netdata/netdata.conf \
	&& tar czf /etc/netdata.tgz -C /etc netdata \
	&& ln -sf /dev/null /var/log/netdata/access.log \
	&& ln -sf /dev/null /var/log/netdata/debug.log \
	&& ln -sf /dev/stderr /var/log/netdata/error.log

#VOLUME ["/etc/netdata" "/var/log/netdata"]

USER netdata

EXPOSE 19999

ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/sbin/netdata"]
