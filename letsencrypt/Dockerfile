#FROM quay.io/letsencrypt/letsencrypt:latest
FROM cedrik/baseimage:latest
MAINTAINER Cédrik LIME

# https://github.com/letsencrypt/letsencrypt/blob/master/Dockerfile

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git python2.7 python-virtualenv \
	&& cd /opt \
	&& git clone https://github.com/letsencrypt/letsencrypt \
	&& /opt/letsencrypt/letsencrypt-auto-source/letsencrypt-auto --os-packages-only \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& virtualenv --no-site-packages -p python2 /opt/letsencrypt/venv && \
		/opt/letsencrypt/venv/bin/pip install \
		-e /opt/letsencrypt/acme \
		-e /opt/letsencrypt \
		-e /opt/letsencrypt/letsencrypt-apache \
		-e /opt/letsencrypt/letsencrypt-nginx

ENV PATH /opt/letsencrypt/venv/bin:$PATH

#VOLUME ["/var/log", "/etc/letsencrypt", "/var/lib/letsencrypt"]

WORKDIR /opt/letsencrypt

EXPOSE 80 443

ENTRYPOINT ["letsencrypt", "--authenticators"]
#CMD ["--help", "all"]
#CMD ["certonly", "--dry-run", "--non-interactive", "--test-cert"]
#CMD ["renew", "--non-interactive", "--keep-until-expiring"]
