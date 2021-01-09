FROM python:3.8-slim
LABEL org.opencontainers.image.authors="Cédrik LIME"

# Install procps & curl (for health check)
#RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-utils && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends procps curl \
#	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN pip install --no-cache-dir --disable-pip-version-check webssh

EXPOSE 8888 4433

USER nobody

WORKDIR /srv

CMD ["wssh", "--log-to-stderr", "--logging=info", "--address=0.0.0.0", "--policy=autoadd", "--encoding=utf-8", "--hostfile=/srv/known_hosts"]
