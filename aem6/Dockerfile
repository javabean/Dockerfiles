FROM cedrik/java:latest
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Cédrik LIME"

# Requires curl, xz & gosu

############### FIXME  change URL here! ###############
ARG AEM_JAR_URL=https://files.docker.myserver.example/aem/6.2/cq-quickstart-6.2.0.1.jar
ARG IMAGEMAGICK=
ARG FFMPEG=

# Create "aem6" user
RUN	if ! getent group "aem6" > /dev/null 2>&1 ; then \
		addgroup --system --gid 4502 "aem6" --quiet ; \
	fi \
	&& if ! id aem6 > /dev/null 2>&1 ; then \
		adduser --system --uid 4502 --home /usr/share/aem6 --no-create-home --ingroup "aem6" --disabled-password --shell /bin/false --gecos "AEM" "aem6" \
		&& usermod -L aem6 \
		&& usermod -a -G docker_env aem6 ; \
	fi

# Install ImageMagick
RUN if [ -n "${IMAGEMAGICK}" ]; then apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends imagemagick \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ; \
	fi

# Install FFmpeg
# Requires xz (CentOS) | xz-utils (Debian)
RUN if [ -n "${FFMPEG}" ]; then curl -fsSL https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-64bit-static.tar.xz | tar xJ -C /usr/local/bin/ --strip-components=1 --exclude="ffmpeg-*-static/manpages" --exclude="ffmpeg-*-static/*.txt"; fi

RUN mkdir -p /srv/aem6/tmp /opt/aem6/packages && chown -R aem6: /srv/aem6 /opt/aem6

COPY docker-entrypoint.sh consul-healthcheck.sh  /usr/local/bin/
COPY aem6  /usr/local/etc/

# ADD creates the remote file with permissions 600, which are not enough for our usage
#ADD ${AEM_JAR_URL}  /opt/aem6/
RUN cd /opt/aem6/ && curl -fsSLRO ${AEM_JAR_URL} && cd -

#VOLUME ["/srv/aem6", "/opt/aem6/packages"]

EXPOSE 4502 4503

#USER aem6

ENTRYPOINT ["/usr/local/sbin/docker-init.sh", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["start"]
